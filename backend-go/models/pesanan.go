package models

import (
	"time"
)

type PesananStatus string
type PaymentStatus string

const (
	PesananPending   PesananStatus = "pending"
	PesananCompleted PesananStatus = "completed"
	PesananCancelled PesananStatus = "cancelled"
	PesananDelivered PesananStatus = "delivered"

	PaymentUnpaid PaymentStatus = "unpaid"
	PaymentPaid   PaymentStatus = "paid"
)

type Pesanan struct {
	ID               uint          `gorm:"primaryKey;autoIncrement"`
	OrderId          string        `gorm:"type:varchar(255);unique;not null"`
	IdempotencyKey   string        `gorm:"type:varchar(255);unique"`
	UserId           uint          `gorm:"not null;index"`
	InvoiceNumber    string        `gorm:"type:varchar(255)"`
	MetodePembayaran string        `gorm:"type:varchar(255);not null"`
	HargaRp          int           `gorm:"type:integer"`
	HargaPoin        int           `gorm:"type:integer"`
	Ongkir           int           `gorm:"type:integer"`
	TotalBayar       int           `gorm:"not null"`
	PaymentStatus    PaymentStatus `gorm:"type:varchar(50);not null;default:'unpaid'"`
	Status           PesananStatus `gorm:"type:varchar(50);not null;default:'pending'"`
	CreatedAt        time.Time     `gorm:"autoCreateTime"`
	UpdatedAt        time.Time     `gorm:"autoUpdateTime"`

	// Associations User
	User User `gorm:"foreignKey:UserId;references:ID"`

	// Has Many OrderItems
	OrderItems []OrderItem `gorm:"foreignKey:PesananID;constraint:OnDelete:CASCADE"`
}

func (Pesanan) TableName() string {
	return "pesanan"
}
