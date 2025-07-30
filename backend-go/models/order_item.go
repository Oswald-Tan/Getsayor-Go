package models

import (
	"time"
)

type OrderItem struct {
	ID         uint      `gorm:"primaryKey;autoIncrement"`
	PesananID  uint      `gorm:"not null;index"`
	ProductID  uint      `gorm:"not null;index"`
	NamaProduk string    `gorm:"type:varchar(255);not null"`
	Harga      int       `gorm:"not null"`
	Jumlah     int       `gorm:"not null"`
	Berat      int       `gorm:"not null"`
	Satuan     string    `gorm:"type:varchar(255);not null"`
	TotalHarga int       `gorm:"not null"`
	CreatedAt  time.Time `gorm:"autoCreateTime"`
	UpdatedAt  time.Time `gorm:"autoUpdateTime"`

	// Belongs To Pesanan
	Pesanan *Pesanan `gorm:"foreignKey:PesananID"`

	// Belongs To Product
	Product *Product `gorm:"foreignKey:ProductID"`
}

func (OrderItem) TableName() string {
	return "order_items"
}
