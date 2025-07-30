package models

type Setting struct {
	Key   string `gorm:"primaryKey;type:varchar(255);not null"`
	Value string `gorm:"type:varchar(255);not null"`
}

func (Setting) TableName() string {
	return "setting"
}
