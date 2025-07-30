package tasks

import (
	"log"
	"time"

	"backend-go/models"

	"gorm.io/gorm"
)

func CheckExpiredBonuses(db *gorm.DB) {
	log.Println("Running cron job to update expired bonuses...")

	currentTime := time.Now()

	result := db.Model(&models.AfiliasiBonus{}).
		Where("status = ? AND expiry_date < ?", "pending", currentTime).
		Update("status", "expired")

	if result.Error != nil {
		log.Println("Error updating expired bonuses:", result.Error)
	} else {
		log.Printf("Updated %d bonuses to status \"expired\"\n", result.RowsAffected)
	}
}
