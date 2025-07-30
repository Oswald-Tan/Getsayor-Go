package models

type TotalBonus struct {
	ID         uint    `gorm:"primaryKey;autoIncrement"`
	UserID     uint    `gorm:"not null;index"`
	TotalBonus float64 `gorm:"type:decimal(12,2)"`
}

func (TotalBonus) TableName() string {
	return "total_bonus"
}
