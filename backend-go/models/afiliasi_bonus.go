package models

import (
	"time"
)

type AfiliasiBonusStatus string

const (
	BonusPending     AfiliasiBonusStatus = "pending"
	BonusClaimed     AfiliasiBonusStatus = "claimed"
	BonusExpired     AfiliasiBonusStatus = "expired"
	BonusTransferred AfiliasiBonusStatus = "transferred"
)

type AfiliasiBonus struct {
	ID              uint                `gorm:"primaryKey;autoIncrement"`
	UserId          uint                `gorm:"not null;index"`
	ReferralUserId  uint                `gorm:"not null;index"`
	PesananId       uint                `gorm:"not null;index"`
	BonusAmount     float64             `gorm:"type:decimal(12,2)"`
	BonusLevel      int                 `gorm:"not null"`
	ExpiryDate      time.Time           `gorm:"not null"`
	Status          AfiliasiBonusStatus `gorm:"type:varchar(20);not null;default:'pending'"`
	ClaimedAt       *time.Time          `gorm:"default:null"`
	BonusReceivedAt time.Time           `gorm:"not null"`
	TransferredAt   *time.Time          `gorm:"default:null"`

	// Associations
	User         User    `gorm:"foreignKey:UserId;references:ID"`
	ReferralUser User    `gorm:"foreignKey:ReferralUserId;references:ID"`
	Pesanan      Pesanan `gorm:"foreignKey:PesananId;references:ID"`
}

func (AfiliasiBonus) TableName() string {
	return "afiliasi_bonus"
}
