package models

type Discount struct {
	ID         uint    `gorm:"primaryKey;autoIncrement"`
	Percentage float64 `gorm:"type:decimal(5,2);not null"`
	PoinID     uint    `gorm:"not null;uniqueIndex"` // One-to-one relationship

	// Relationship
	Poin *Poin `gorm:"foreignKey:PoinID"`
}

func (Discount) TableName() string {
	return "discounts"
}
