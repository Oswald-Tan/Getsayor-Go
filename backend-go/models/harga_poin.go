package models

type HargaPoin struct {
	ID    uint `gorm:"primaryKey;autoIncrement"`
	Harga int  `gorm:"not null"`
}

func (HargaPoin) TableName() string {
	return "hargapoin"
}
