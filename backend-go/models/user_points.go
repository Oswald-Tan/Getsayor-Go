package models

import (
	"time"
)

type UserPoints struct {
	ID        uint      `gorm:"primaryKey;autoIncrement"`
	UserID    uint      `gorm:"not null;index"`
	Points    int       `gorm:"not null;default:0"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
	UpdatedAt time.Time `gorm:"autoUpdateTime"`

	User *User `gorm:"foreignKey:UserID"`
}

func (UserPoints) TableName() string {
	return "user_points"
}
