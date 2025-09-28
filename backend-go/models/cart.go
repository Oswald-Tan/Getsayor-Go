package models

import (
	"time"
)

type Cart struct {
	ID            uint      `gorm:"primaryKey;autoIncrement"`
	UserID        uint      `gorm:"not null;index"`
	ProductItemID uint      `gorm:"not null;index"`
	Quantity      int       `gorm:"not null"`
	Notes         string    `gorm:"type:text"`
	Status        string    `gorm:"type:varchar(50);not null;default:'active'"`
	CreatedAt     time.Time `gorm:"autoCreateTime"`
	UpdatedAt     time.Time `gorm:"autoUpdateTime"`

	// Relationships
	User        *User        `gorm:"foreignKey:UserID"`
	ProductItem *ProductItem `gorm:"foreignKey:ProductItemID;references:ID" json:"product_item"`
	Items       []CartItem   `gorm:"foreignKey:CartID"`
}

func (Cart) TableName() string {
	return "carts"
}
