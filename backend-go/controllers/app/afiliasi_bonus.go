package app

import (
	"errors"
	"net/http"
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

// ClaimBonus handles bonus claim
func (ctrl *AfiliasiBonusController) ClaimBonus(c *gin.Context) {
	type RequestBody struct {
		BonusID uint `json:"bonusId" binding:"required"`
	}

	var reqBody RequestBody
	if err := c.ShouldBindJSON(&reqBody); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"message": "Invalid request body"})
		return
	}

	tx := ctrl.DB.Begin()

	// Find pending bonus
	var bonus models.AfiliasiBonus
	if err := tx.Where("id = ? AND status = ?", reqBody.BonusID, models.BonusPending).First(&bonus).Error; err != nil {
		tx.Rollback()
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"message": "Bonus not found or already claimed"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		}
		return
	}

	// Check if bonus is expired
	if time.Now().After(bonus.ExpiryDate) {
		bonus.Status = models.BonusExpired
		if err := tx.Save(&bonus).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update bonus status"})
			return
		}
		tx.Commit()
		c.JSON(http.StatusBadRequest, gin.H{"message": "Bonus has expired and cannot be claimed"})
		return
	}

	bonusAmount := bonus.BonusAmount

	// Find or create total bonus
	var totalBonus models.TotalBonus
	if err := tx.Where("user_id = ?", bonus.UserId).First(&totalBonus).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			// Create new total bonus
			totalBonus = models.TotalBonus{
				UserID:     bonus.UserId,
				TotalBonus: bonusAmount,
			}
			if err := tx.Create(&totalBonus).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to create total bonus"})
				return
			}
		} else {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
			return
		}
	} else {
		// Check if total bonus exceeds 500000
		if totalBonus.TotalBonus+bonusAmount > 500000 {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{"message": "Total bonus already reached 500,000"})
			return
		}

		// Update total bonus
		totalBonus.TotalBonus += bonusAmount
		if err := tx.Save(&totalBonus).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update total bonus"})
			return
		}
	}

	// Update bonus status
	now := time.Now()
	bonus.Status = models.BonusClaimed
	bonus.ClaimedAt = &now
	if err := tx.Save(&bonus).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"message": "Failed to update bonus status"})
		return
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{
		"message":    "Bonus claimed and total bonus updated successfully",
		"bonus":      bonus,
		"totalBonus": totalBonus,
	})
}

// GetTotalBonus handles GET /afiliasi/total/:userId
func (ctrl *AfiliasiBonusController) GetTotalBonus(c *gin.Context) {
	userID := c.Param("userId")

	var totalBonus float64 // Ubah tipe data menjadi float64
	if err := ctrl.DB.Model(&models.AfiliasiBonus{}).
		Where("user_id = ? AND status = ?", userID, models.BonusClaimed).
		Select("COALESCE(SUM(bonus_amount), 0)").
		Scan(&totalBonus).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":    "Total bonus retrieved successfully",
		"totalBonus": totalBonus,
	})
}

// GetPendingBonus handles GET /afiliasi/pending/:userId
func (ctrl *AfiliasiBonusController) GetPendingBonus(c *gin.Context) {
	userID := c.Param("userId")

	var pendingBonuses []models.AfiliasiBonus
	if err := ctrl.DB.
		Joins("JOIN pesanan ON afiliasi_bonus.pesanan_id = pesanan.id").
		Where("afiliasi_bonus.user_id = ? AND afiliasi_bonus.status = ? AND pesanan.status = ?",
			userID, models.BonusPending, models.PesananDelivered).
		Order("afiliasi_bonus.expiry_date ASC").
		Find(&pendingBonuses).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	if len(pendingBonuses) == 0 {
		c.JSON(http.StatusOK, gin.H{
			"message":      "No pending bonus to claim",
			"pendingBonus": []string{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":      "Pending bonuses retrieved successfully",
		"pendingBonus": pendingBonuses,
	})
}

// GetExpiredBonus handles GET /afiliasi/expired/:userId
func (ctrl *AfiliasiBonusController) GetExpiredBonus(c *gin.Context) {
	userID := c.Param("userId")

	var expiredBonuses []models.AfiliasiBonus
	if err := ctrl.DB.Where("user_id = ? AND status = ?", userID, models.BonusExpired).
		Order("expiry_date ASC").
		Find(&expiredBonuses).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	if len(expiredBonuses) == 0 {
		c.JSON(http.StatusOK, gin.H{
			"message":      "No expired bonus",
			"expiredBonus": []string{},
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":      "Expired bonuses retrieved successfully",
		"expiredBonus": expiredBonuses,
	})
}
