package models

type DetailsUser struct {
	ID           uint   `gorm:"primaryKey;autoIncrement"`
	UserID       uint   `gorm:"not null;uniqueIndex"` // Foreign key ke User
	Fullname     string `gorm:"type:varchar(255)"`
	PhoneNumber  string `gorm:"type:varchar(255)"`
	PhotoProfile string `gorm:"type:varchar(255)"`

	User *User `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
}

func (DetailsUser) TableName() string {
	return "details_users"
}
