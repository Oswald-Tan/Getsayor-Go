package models

type ShippingRate struct {
	ID     uint    `gorm:"primaryKey;autoIncrement"`
	CityID uint    `gorm:"not null;index"`
	Price  float64 `gorm:"type:decimal(10,2);not null"`

	// Belongs To City
	City *City `gorm:"foreignKey:CityID"`
}

func (ShippingRate) TableName() string {
	return "shipping_rates"
}
