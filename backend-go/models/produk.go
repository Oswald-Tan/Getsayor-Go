package models

import (
	"time"
)

type Product struct {
	ID         uint      `gorm:"primaryKey;autoIncrement"`
	NameProduk string    `gorm:"type:varchar(100);not null" validate:"required,min=3,max=100"`
	Deskripsi  string    `gorm:"type:text;not null"`
	Kategori   string    `gorm:"type:varchar(255);not null"`
	Stok       int       `gorm:"not null;default:0" validate:"min=0"`
	HargaPoin  int       `gorm:"not null"`
	HargaRp    int       `gorm:"not null"`
	Jumlah     int       `gorm:"not null"`
	Satuan     string    `gorm:"type:varchar(255);not null"`
	Image      string    `gorm:"type:varchar(255)"`
	CreatedAt  time.Time `gorm:"autoCreateTime"`
	UpdatedAt  time.Time `gorm:"autoUpdateTime"`

	//Favorite
	Favorites []Favorite `gorm:"foreignKey:ProductID"`

	//Cart & Cart Items
	Carts     []Cart     `gorm:"foreignKey:ProductID"`
	CartItems []CartItem `gorm:"foreignKey:ProductID"`
}

func (Product) TableName() string {
	return "products"
}
