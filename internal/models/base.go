package models

import (
	"time"
)

type Base struct {
	ID        uuid `gorm:"type:uuid,primary_key;default:uuid_generate_v4()"`
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt *time.Time `sql:"index"`
}
