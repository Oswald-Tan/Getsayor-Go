package models

type Province struct {
	ID   uint   `gorm:"primaryKey;autoIncrement"`
	Name string `gorm:"type:varchar(255);not null"`

	// Has Many Cities
	Cities []City `gorm:"foreignKey:ProvinceID"`
}

func (Province) TableName() string {
	return "provinces"
}
