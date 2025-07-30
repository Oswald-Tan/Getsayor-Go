package models

import (
	"time"
)

type Address struct {
	ID            uint   `gorm:"primaryKey;autoIncrement"`
	UserID        uint   `gorm:"not null;index"`
	RecipientName string `gorm:"type:varchar(255);not null"`
	PhoneNumber   string `gorm:"type:varchar(20);not null"`
	AddressLine1  string `gorm:"type:text;not null"`
	City          string `gorm:"type:varchar(100);default:'Manado'"`

	State      string    `gorm:"type:varchar(100);default:'Sulawesi Utara'"`
	PostalCode string    `gorm:"type:varchar(20)"`
	IsDefault  bool      `gorm:"default:false"`
	CreatedAt  time.Time `gorm:"autoCreateTime"`
	UpdatedAt  time.Time `gorm:"autoUpdateTime"`

	// Belongs To User
	User *User `gorm:"foreignKey:UserID"`
}

func (Address) TableName() string {
	return "address"
}
