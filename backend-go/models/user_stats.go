package models

import (
	"time"
)

type UserStats struct {
	ID          uint       `gorm:"primaryKey;autoIncrement"`
	UserID      uint       `gorm:"not null;uniqueIndex"` // One-to-one relationship (unique)
	LastLogin   *time.Time `gorm:"type:timestamp"`       // Nullable
	TotalLogins int        `gorm:"not null;default:0"`

	User *User `gorm:"foreignKey:UserID"`
}

func (UserStats) TableName() string {
	return "user_stats"
}
