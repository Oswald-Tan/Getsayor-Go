package models

type Role struct {
	ID       uint   `gorm:"primaryKey;autoIncrement"`
	RoleName string `gorm:"type:varchar(255);unique;not null"`

	// Association
	Users []User `gorm:"foreignKey:RoleID"`
}

func (Role) TableName() string {
	return "roles"
}
