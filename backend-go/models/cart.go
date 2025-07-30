package models

import (
	"time"
)

type Cart struct {
	ID        uint      `gorm:"primaryKey;autoIncrement"`
	UserID    uint      `gorm:"not null;index"`
	ProductID string    `gorm:"type:varchar(255);not null;index"`
	Quantity  int       `gorm:"not null"`
	Notes     string    `gorm:"type:text"`
	Status    string    `gorm:"type:varchar(50);not null;default:'active'"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
	UpdatedAt time.Time `gorm:"autoUpdateTime"`

	// Relationships
	User    *User      `gorm:"foreignKey:UserID"`
	Product *Product   `gorm:"foreignKey:ProductID;references:ID"`
	Items   []CartItem `gorm:"foreignKey:CartID"`
}

func (Cart) TableName() string {
	return "carts"
}
