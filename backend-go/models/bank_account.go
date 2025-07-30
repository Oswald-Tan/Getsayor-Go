package models

import (
	"time"
)

type BankAccount struct {
	ID            uint      `gorm:"primaryKey;autoIncrement"`
	UserID        uint      `gorm:"not null;index"`
	AccountHolder string    `gorm:"type:varchar(255);not null"`
	BankName      string    `gorm:"type:varchar(255);not null"`
	AccountNumber string    `gorm:"type:varchar(255);not null;unique"`
	CreatedAt     time.Time `gorm:"autoCreateTime"`
	UpdatedAt     time.Time `gorm:"autoUpdateTime"`

	// Belongs To User
	User *User `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
}

func (BankAccount) TableName() string {
	return "bank_accounts"
}
