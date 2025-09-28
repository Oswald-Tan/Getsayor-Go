package app

import (
	"time"

	"gorm.io/gorm"

	"backend-go/models"
)

type UserStatsAppController struct {
	DB *gorm.DB
}

func NewUserStatsAppController(db *gorm.DB) *UserStatsAppController {
	return &UserStatsAppController{DB: db}
}

// CreateOrUpdateUserStats creates or updates user stats
func (ctrl *UserStatsAppController) CreateOrUpdateUserStats(userID uint) (*models.UserStats, error) {
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
