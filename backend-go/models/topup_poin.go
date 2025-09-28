package models

import (
	"time"
)

type TopUpPoin struct {
	ID            uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	TopupID       string    `gorm:"type:varchar(255);not null;uniqueIndex"`
	PurchaseID    string    `gorm:"type:varchar(255);not null"`
	InvoiceNumber string    `gorm:"type:varchar(255);not null;uniqueIndex"`
	UserID        uint      `gorm:"not null;index"`
	Points        int       `gorm:"not null"`
	Price         int       `gorm:"not null"`
	PaymentMethod string    `gorm:"type:varchar(255);not null"`
	Status        string    `gorm:"type:varchar(255);not null;default:'success'"`
	CreatedAt     time.Time `gorm:"autoCreateTime"`
	UpdatedAt     time.Time `gorm:"autoUpdateTime"`

	// Belongs To relationship with User
	User *User `gorm:"foreignKey:UserID"` // Pointer to avoid recursive issues
}

func (TopUpPoin) TableName() string {
	return "topuppoin"
}
