package models

import (
	"time"
)

type Product struct {
	ID         uint      `gorm:"primaryKey;autoIncrement"`
	NameProduk string    `gorm:"type:varchar(100);not null" validate:"required,min=3,max=100"`
	Deskripsi  string    `gorm:"type:text;not null"`
	Kategori   string    `gorm:"type:varchar(255);not null;index"`
	Image      string    `gorm:"type:varchar(255)"`
	CreatedAt  time.Time `gorm:"autoCreateTime"`
	UpdatedAt  time.Time `gorm:"autoUpdateTime"`

	ProductItems []ProductItem `gorm:"foreignKey:ProductID"`

	Favorites []Favorite `gorm:"foreignKey:ProductID"`
}

type ProductItem struct {
	ID        uint      `gorm:"primaryKey;autoIncrement"`
	ProductID uint      `gorm:"not null;index"`
	Stok      int       `gorm:"not null;default:0" validate:"min=0"` //stok
	HargaPoin int       `gorm:"not null"`
	HargaRp   int       `gorm:"not null"`
	Jumlah    int       `gorm:"not null"`                        //misalnya 1kg, 500gr, 1buah, 1ikat
	Satuan    string    `gorm:"type:varchar(50);not null;index"` //misalnya kg, gr, buah, ikat
	CreatedAt time.Time `gorm:"autoCreateTime"`
	UpdatedAt time.Time `gorm:"autoUpdateTime"`

	Product *Product `gorm:"foreignKey:ProductID"`

	// Tambahkan relasi ke Cart jika diperlukan
	Carts []Cart `gorm:"foreignKey:ProductItemID"`
}

func (Product) TableName() string {
	return "products"
}

func (ProductItem) TableName() string {
	return "product_items"
}
