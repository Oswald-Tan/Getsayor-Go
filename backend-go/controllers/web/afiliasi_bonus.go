package web

import (
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type AfiliasiBonusController struct {
	DB *gorm.DB
}

func NewAfiliasiBonusController(db *gorm.DB) *AfiliasiBonusController {
	return &AfiliasiBonusController{DB: db}
}

type AfiliasiBonusResponse struct {
	ID             uint                 `json:"id"`
	UserId         uint                 `json:"user_id"`
	ReferralUserId uint                 `json:"referral_user_id"`
	BonusAmount    float64              `json:"bonus_amount"`
	BonusLevel     int                  `json:"bonus_level"`
	ExpiryDate     time.Time            `json:"expiry_date"`
	Status         string               `json:"status"`
	ClaimedAt      *time.Time           `json:"claimed_at,omitempty"`
	TransferredAt  *time.Time           `json:"transferred_at,omitempty"`
	User           UserResponse         `json:"user"`
	ReferralUser   ReferralUserResponse `json:"referral_user"`
	Pesanan        PesananResponse      `json:"pesanan"`
}

type UserResponse struct {
	ID       uint                 `json:"id"`
	Email    string               `json:"email"`
	Fullname string               `json:"fullname"`
	Phone    string               `json:"phone"`
	Bank     *BankAccountResponse `json:"bank,omitempty"`
}

type BankAccountResponse struct {
	AccountHolder string `json:"account_holder"`
	BankName      string `json:"bank_name"`
	AccountNumber string `json:"account_number"`
}

type ReferralUserResponse struct {
	ID    uint   `json:"id"`
	Email string `json:"email"`
}

type PesananResponse struct {
	ID         uint   `json:"id"`
	OrderId    string `json:"order_id"`
	TotalBayar int    `json:"total_bayar"`
	Status     string `json:"status"`
}

func (ctrl *AfiliasiBonusController) GetAfiliasiBonuses(c *gin.Context) {
	// Get pagination parameters
	page, _ := strconv.Atoi(c.DefaultQuery("page", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	status := c.Query("status")
	search := c.Query("search")
	order := c.DefaultQuery("order", "asc") // "asc" or "desc"
	offset := page * limit

	// Build query
	query := ctrl.DB.
		Preload("User").
		Preload("User.Details").
		Preload("User.BankAccount").
		Preload("ReferralUser").
		Preload("Pesanan").
		Joins("LEFT JOIN users ON users.id = afiliasi_bonus.user_id").
		Joins("LEFT JOIN details_users ON details_users.user_id = users.id")

	if status != "" && status != "all" {
		query = query.Where("afiliasi_bonus.status = ?", status)
	}

	if search != "" {
		search = strings.ToLower(search)
		query = query.Where("LOWER(details_users.fullname) LIKE ?", "%"+search+"%")
	}

	// Handle ordering
	orderClause := "details_users.fullname"
	if strings.ToLower(order) == "desc" {
		orderClause += " DESC"
	} else {
		orderClause += " ASC"
	}
	query = query.Order(orderClause)

	// Count total rows
	var totalRows int64
	countQuery := ctrl.DB.Model(&models.AfiliasiBonus{})
	if status != "" && status != "all" {
		countQuery = countQuery.Where("status = ?", status)
	}

	if search != "" {
		searchLower := strings.ToLower(search)
		countQuery = countQuery.
			Joins("LEFT JOIN users ON users.id = afiliasi_bonus.user_id").
			Joins("LEFT JOIN details_users ON details_users.user_id = users.id").
			Where("LOWER(details_users.fullname) LIKE ?", "%"+searchLower+"%")
	}

	if err := countQuery.Count(&totalRows).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to count bonuses",
			"error":   err.Error(),
		})
		return
	}

	// Calculate total pages
	totalPage := (int(totalRows) + limit - 1) / limit // Ceil division

	// Get paginated data
	var bonuses []models.AfiliasiBonus
	err := query.Offset(offset).Limit(limit).Find(&bonuses).Error
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to fetch bonuses",
			"error":   err.Error(),
		})
		return
	}

	// Map to response struct
	response := make([]AfiliasiBonusResponse, len(bonuses))
	for i, bonus := range bonuses {
		userRes := UserResponse{
			ID:    bonus.User.ID,
			Email: bonus.User.Email,
		}

		if bonus.User.Details != nil {
			userRes.Fullname = bonus.User.Details.Fullname
			userRes.Phone = bonus.User.Details.PhoneNumber
		}

		if bonus.User.BankAccount != nil {
			userRes.Bank = &BankAccountResponse{
				AccountHolder: bonus.User.BankAccount.AccountHolder,
				BankName:      bonus.User.BankAccount.BankName,
				AccountNumber: bonus.User.BankAccount.AccountNumber,
			}
		}

		refUserRes := ReferralUserResponse{
			ID:    bonus.ReferralUser.ID,
			Email: bonus.ReferralUser.Email,
		}

		pesananRes := PesananResponse{
			ID:         bonus.Pesanan.ID,
			OrderId:    bonus.Pesanan.OrderId,
			TotalBayar: bonus.Pesanan.TotalBayar,
			Status:     string(bonus.Pesanan.Status),
		}

		response[i] = AfiliasiBonusResponse{
			ID:             bonus.ID,
			UserId:         bonus.UserId,
			ReferralUserId: bonus.ReferralUserId,
			BonusAmount:    bonus.BonusAmount,
			BonusLevel:     bonus.BonusLevel,
			ExpiryDate:     bonus.ExpiryDate,
			Status:         string(bonus.Status),
			ClaimedAt:      bonus.ClaimedAt,
			TransferredAt:  bonus.TransferredAt,
			User:           userRes,
			ReferralUser:   refUserRes,
			Pesanan:        pesananRes,
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success":   true,
		"data":      response,
		"page":      page,
		"limit":     limit,
		"totalPage": totalPage,
		"totalRows": totalRows,
		"order":     order,
		"search":    search,
	})
}

func (ctrl *AfiliasiBonusController) ClaimBonus(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"message": "User not authenticated",
		})
		return
	}

	bonusID := c.Param("id")
	var bonus models.AfiliasiBonus

	if err := ctrl.DB.Preload("User").First(&bonus, bonusID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{
			"success": false,
			"message": "Bonus not found",
		})
		return
	}

	// Cek apakah bonus milik user yang login
	if bonus.UserId != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{
			"success": false,
			"message": "You don't have permission to claim this bonus",
		})
		return
	}

	// Cek status bonus
	if bonus.Status != models.BonusPending {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Bonus is not in pending status",
		})
		return
	}

	// Cek apakah bonus sudah expired
	if time.Now().After(bonus.ExpiryDate) {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Bonus has expired",
		})
		return
	}

	// Update status bonus
	now := time.Now()
	bonus.Status = models.BonusClaimed
	bonus.ClaimedAt = &now

	if err := ctrl.DB.Save(&bonus).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to claim bonus",
			"error":   err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Bonus claimed successfully",
		"data":    bonus,
	})
}

func (ctrl *AfiliasiBonusController) TransferBonus(c *gin.Context) {
	id := c.Param("id")

	// Cari bonus berdasarkan ID
	var bonus models.AfiliasiBonus
	if err := ctrl.DB.First(&bonus, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Bonus not found"})
		return
	}

	// Pastikan statusnya adalah claimed
	if bonus.Status != models.BonusClaimed {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Bonus status must be claimed before transferring"})
		return
	}

	// Update status menjadi transferred dan set transferred_at
	now := time.Now()
	bonus.Status = models.BonusTransferred
	bonus.TransferredAt = &now

	if err := ctrl.DB.Save(&bonus).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Bonus transferred successfully"})
}
