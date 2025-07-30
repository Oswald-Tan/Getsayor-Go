package models

import (
	"time"
)

type CartItem struct {
	ID             uint      `gorm:"primaryKey;autoIncrement"`
	CartID         uint      `gorm:"not null;index"`
	ProductID      uint      `gorm:"not null;index"`
	Quantity       int       `gorm:"not null;default:1"`
	TotalHargaPoin int       `gorm:"not null"`
	TotalHargaRp   int       `gorm:"not null"`
	CreatedAt      time.Time `gorm:"autoCreateTime"`
	UpdatedAt      time.Time `gorm:"autoUpdateTime"`

	// Relationships
	Cart    *Cart    `gorm:"foreignKey:CartID"`
	Product *Product `gorm:"foreignKey:ProductID"`
}

func (CartItem) TableName() string {
	return "cart_items"
}
