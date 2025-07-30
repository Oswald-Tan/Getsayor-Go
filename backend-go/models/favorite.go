package models

import "time"

type Favorite struct {
	ID        uint      `gorm:"primaryKey;autoIncrement"`
	UserID    uint      `gorm:"not null;index:idx_user_product,unique"`
	ProductID uint      `gorm:"not null;index:idx_user_product,unique"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
	UpdatedAt time.Time `gorm:"autoUpdateTime"`

	// Relationships
	User    User     `gorm:"foreignKey:UserID;references:ID"`
	Product *Product `gorm:"foreignKey:ProductID;references:ID"`
}

func (Favorite) TableName() string {
	return "favorites"
}
