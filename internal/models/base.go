package models

import (
	"github.com/docker/distribution/uuid"
	"time"
)

type Base struct {
	ID        uuid.UUID `gorm:"type:uuid,primary_key;default:uuid_generate_v4()"`
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt *time.Time `sql:"index"`
}
