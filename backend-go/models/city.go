package models

type City struct {
	ID         uint   `gorm:"primaryKey;autoIncrement"`
	Name       string `gorm:"type:varchar(255);not null"`
	ProvinceID uint   `gorm:"not null;index"`

	// Belongs To Province
	Province *Province `gorm:"foreignKey:ProvinceID"`

	// Has One ShippingRate
	ShippingRate *ShippingRate `gorm:"foreignKey:CityID"`
}

func (City) TableName() string {
	return "cities"
}
