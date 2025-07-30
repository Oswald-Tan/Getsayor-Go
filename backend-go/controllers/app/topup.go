package app

import (
	"backend-go/models"
	push "backend-go/utils"
	"errors"
	"fmt"
	"math"
	"math/rand"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type TopUpPoinController struct {
	DB *gorm.DB
}

func NewTopUpPoinController(db *gorm.DB) *TopUpPoinController {
	return &TopUpPoinController{DB: db}
}

func (ctrl *TopUpPoinController) GetTopUp(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	search := c.Query("search")

	offset := limit * page
	var totalRows int64

	// Build query with search condition
	query := ctrl.DB.Model(&models.TopUpPoin{}).Preload("User.Details")
	if search != "" {
		query = query.Joins("JOIN users ON users.id = topuppoin.user_id").
			Joins("JOIN details_users ON details_users.user_id = users.id").
			Where("details_users.fullname ILIKE ?", "%"+search+"%")
	}

	// Get total count
	if err := query.Count(&totalRows).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	totalPage := int(math.Ceil(float64(totalRows) / float64(limit)))

	// Fetch paginated data
	var topUps []models.TopUpPoin
	if err := query.Order("created_at DESC").
		Offset(offset).Limit(limit).
		Find(&topUps).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data":      topUps,
		"page":      page,
		"limit":     limit,
		"totalPage": totalPage,
		"totalRows": totalRows,
	})
}

func (ctrl *TopUpPoinController) GetTotalApprovedTopUp(c *gin.Context) {
	var count int64
	if err := ctrl.DB.Model(&models.TopUpPoin{}).
		Where("status = ?", "success").
		Count(&count).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"totalTopUp": count})
}

func (ctrl *TopUpPoinController) GetTopUpById(c *gin.Context) {
	id := c.Param("id")

	var topUp models.TopUpPoin
	if err := ctrl.DB.Where("id = ?", id).First(&topUp).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"message": "Top Up not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		}
		return
	}

	c.JSON(http.StatusOK, topUp)
}

func (ctrl *TopUpPoinController) GetTopUpByUserId(c *gin.Context) {
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"message": "User not authenticated"})
		return
	}

	var topUps []models.TopUpPoin
	if err := ctrl.DB.Where("user_id = ?", userID).
		Order("created_at DESC").
		Find(&topUps).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	if len(topUps) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"message": "Belum ada Top Up"})
		return
	}

	c.JSON(http.StatusOK, topUps)
}

func (ctrl *TopUpPoinController) GetTotalTopUp(c *gin.Context) {
	period := c.Param("period")

	now := time.Now()
	var startDate time.Time

	switch period {
	case "weekly":
		startDate = now.AddDate(0, 0, -7)
	case "monthly":
		startDate = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
	case "yearly":
		startDate = time.Date(now.Year(), 1, 1, 0, 0, 0, 0, now.Location())
	default:
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid period"})
		return
	}

	endDate := now

	var total int64
	if err := ctrl.DB.Model(&models.TopUpPoin{}).
		Select("COALESCE(SUM(price), 0)").
		Where("status = ? AND created_at BETWEEN ? AND ?", "success", startDate, endDate).
		Scan(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"total": total})
}

// generateUniqueTopupId generates unique topup ID
func generateUniqueTopupId() string {
	return fmt.Sprintf("TP-%d%d", time.Now().Unix(), rand.Intn(1000))
}

func (ctrl *TopUpPoinController) PostTopUp(c *gin.Context) {
	var input struct {
		Points        int    `json:"points" binding:"required"`
		Price         int    `json:"price" binding:"required"`
		Date          string `json:"date"`
		PaymentMethod string `json:"paymentMethod" binding:"required"`
		UserID        uint   `json:"userId" binding:"required"`
		PurchaseID    string `json:"purchaseId" binding:"required"`
		InvoiceNumber string `json:"invoiceNumber" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
		return
	}

	// Validate purchaseId format
	if !isValidPurchaseID(input.PurchaseID) {
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  "error",
			"message": "Invalid purchaseId format",
		})
		return
	}

	// Start transaction
	tx := ctrl.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Check user existence
	var user models.User
	if err := tx.Preload("Details").First(&user, input.UserID).Error; err != nil {
		tx.Rollback()
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{
				"status":  "error",
				"message": "User not found",
			})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		}
		return
	}

	// Check for existing purchaseId
	var existingTopUp models.TopUpPoin
	if err := tx.Where("purchase_id = ?", input.PurchaseID).First(&existingTopUp).Error; err == nil {
		tx.Rollback()
		c.JSON(http.StatusOK, gin.H{
			"status":     "success",
			"message":    "Purchase already processed",
			"topUpData":  existingTopUp,
			"userPoints": nil, // Not applicable
		})
		return
	}

	// Check for duplicate invoice number
	if err := tx.Where("invoice_number = ?", input.InvoiceNumber).First(&existingTopUp).Error; err == nil {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{
			"status":  "error",
			"message": "Invoice number already exists",
		})
		return
	}

	// Check for recent duplicate
	tenSecAgo := time.Now().Add(-10 * time.Second)
	if err := tx.Where("user_id = ? AND created_at > ?", input.UserID, tenSecAgo).
		First(&existingTopUp).Error; err == nil {
		tx.Rollback()
		c.JSON(http.StatusOK, gin.H{
			"status":     "success",
			"message":    "Recent duplicate blocked",
			"topUpData":  existingTopUp,
			"userPoints": nil, // Not applicable
		})
		return
	}

	// Create new top-up
	topUpData := models.TopUpPoin{
		TopupID:       generateUniqueTopupId(),
		PurchaseID:    input.PurchaseID,
		InvoiceNumber: input.InvoiceNumber,
		UserID:        input.UserID,
		Points:        input.Points,
		Price:         input.Price,
		PaymentMethod: input.PaymentMethod,
		Status:        "success",
	}

	if err := tx.Create(&topUpData).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	// Update user points
	var userPoints models.UserPoints
	if err := tx.Where("user_id = ?", input.UserID).First(&userPoints).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			userPoints = models.UserPoints{
				UserID: input.UserID,
				Points: input.Points,
			}
			if err := tx.Create(&userPoints).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
				return
			}
		} else {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
			return
		}
	} else {
		userPoints.Points += input.Points
		if err := tx.Save(&userPoints).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
			return
		}
	}

	// Commit transaction
	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	// Send push notification if FCM token exists
	if user.FCMToken != "" {
		fullName := ""
		if user.Details != nil {
			fullName = user.Details.Fullname
		}

		firstName := extractFirstName(fullName)
		go push.SendTopupNotification(user.FCMToken, input.Points, input.Price, firstName)
	}

	c.JSON(http.StatusCreated, gin.H{
		"status":     "success",
		"message":    "Top Up successful",
		"topUpData":  topUpData,
		"userPoints": userPoints.Points,
	})
}

// Helper functions
func isValidPurchaseID(purchaseID string) bool {
	return len(purchaseID) > 0 && strings.ContainsAny(purchaseID, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-")
}

func extractFirstName(fullName string) string {
	if fullName == "" {
		return "Pelanggan"
	}

	parts := strings.Fields(fullName)
	if len(parts) == 0 {
		return "Pelanggan"
	}

	firstName := parts[0]
	if len(firstName) > 0 {
		return strings.ToUpper(firstName[:1]) + strings.ToLower(firstName[1:])
	}
	return "Pelanggan"
}
