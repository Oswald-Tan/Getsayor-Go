package web

import (
	"errors"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"backend-go/models"
)

type UserStatsController struct {
	DB *gorm.DB
}

func NewUserStatsController(db *gorm.DB) *UserStatsController {
	return &UserStatsController{DB: db}
}

// CreateOrUpdateUserStats creates or updates user stats
func (ctrl *UserStatsController) CreateOrUpdateUserStats(userID uint) (*models.UserStats, error) {
	var userStats models.UserStats

	// Check if user stats exists
	result := ctrl.DB.Where("user_id = ?", userID).First(&userStats)

	if result.Error == gorm.ErrRecordNotFound {
		// Create new stats
		now := time.Now()
		userStats = models.UserStats{
			UserID:      userID,
			LastLogin:   &now,
			TotalLogins: 1,
		}
		if err := ctrl.DB.Create(&userStats).Error; err != nil {
			return nil, err
		}
	} else if result.Error != nil {
		return nil, result.Error
	} else {
		// Update existing stats
		now := time.Now()
		userStats.LastLogin = &now
		userStats.TotalLogins += 1
		if err := ctrl.DB.Save(&userStats).Error; err != nil {
			return nil, err
		}
	}

	return &userStats, nil
}

// GetUserStats handles GET /users/:id/stats
func (ctrl *UserStatsController) GetUserStats(c *gin.Context) {
	userID := c.Param("id")

	var userStats models.UserStats
	var user models.User

	// 1. Coba dapatkan user_stats
	err := ctrl.DB.Preload("User.Details").
		Where("user_id = ?", userID).
		First(&userStats).Error

	// Handle error selain "not found"
	if err != nil && err != gorm.ErrRecordNotFound {
		c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
		return
	}

	// 2. Jika user_stats tidak ditemukan
	if errors.Is(err, gorm.ErrRecordNotFound) {
		// PERBAIKAN: Query tabel users biasa
		err := ctrl.DB.Preload("Details").
			Where("id = ?", userID).
			First(&user).Error

		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				c.JSON(http.StatusNotFound, gin.H{"message": "User not found"})
			} else {
				c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
			}
			return
		}

		// Pastikan Details tidak nil
		fullname := ""
		if user.Details != nil {
			fullname = user.Details.Fullname
		}

		c.JSON(http.StatusOK, gin.H{
			"fullname":     fullname,
			"email":        user.Email,
			"last_login":   nil,
			"total_logins": 0,
		})
		return
	}

	// 3. Jika user_stats ditemukan
	fullname := ""
	if userStats.User != nil && userStats.User.Details != nil {
		fullname = userStats.User.Details.Fullname
	}

	c.JSON(http.StatusOK, gin.H{
		"fullname":     fullname,
		"email":        userStats.User.Email,
		"last_login":   userStats.LastLogin,
		"total_logins": userStats.TotalLogins,
	})
}
