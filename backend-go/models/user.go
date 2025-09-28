package models

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID              uint   `gorm:"primaryKey;autoIncrement"`
	Email           string `gorm:"type:varchar(255);unique;not null"`
	Password        string `gorm:"type:varchar(255);not null"`
	RoleID          uint   `gorm:"not null"`
	ReferralCode    string `gorm:"type:varchar(255);uniqueIndex"`
	ReferredBy      *uint  `gorm:"index"`
	ReferralUsedAt  *time.Time
	ResetOtp        *string `gorm:"type:varchar(255)"`
	ResetOtpExpires *time.Time
	IsApproved      bool           `gorm:"default:false"`
	FCMToken        string         `gorm:"type:varchar(255)"`
	CreatedAt       time.Time      `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt       time.Time      `gorm:"column:updated_at;autoUpdateTime"`
	DeletedAt       gorm.DeletedAt `gorm:"index"`

	// Associations
	Details   *DetailsUser `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Role      *Role        `gorm:"foreignKey:RoleID"`
	Referrer  *User        `gorm:"foreignKey:ReferredBy;references:ID"`
	Referrals []User       `gorm:"foreignKey:ReferredBy;references:ID"`

	//Association User Point
	Points *UserPoints `gorm:"foreignKey:UserID"`

	//Association User Stats
	Stats *UserStats `gorm:"foreignKey:UserID"`

	//Association Total Bonus
	Bonus *TotalBonus `gorm:"foreignKey:UserID"`

	// Has Many relationship with TopUpPoin
	TopUpPoints []TopUpPoin `gorm:"foreignKey:UserID"`

	//Favorite
	Favorites []Favorite `gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`

	//Cart
	Carts []Cart `gorm:"foreignKey:UserID"`

	// One-to-one relationship with BankAccount
	BankAccount *BankAccount `gorm:"foreignKey:UserID"`

	// One-to-many relationship with Address
	Addresses []Address `gorm:"foreignKey:UserID"`
}

func (User) TableName() string {
	return "users"
}
