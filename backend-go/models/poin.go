package models

type Poin struct {
	ID             uint   `gorm:"primaryKey;autoIncrement"`
	Poin           int    `gorm:"not null"`
	ProductID      string `gorm:"type:varchar(255);not null"` // Changed to string type
	PromoProductID string `gorm:"type:varchar(255)"`          // Nullable string

	//Diskon
	Discount *Discount `gorm:"foreignKey:PoinID"` // One-to-one
}

func (Poin) TableName() string {
	return "poin"
}
