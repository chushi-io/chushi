package user

import (
	"errors"
	"github.com/google/uuid"
	"time"
)

type User struct {
	ID        uuid.UUID  `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `sql:"index" json:"deleted_at"`
	Email     string     `gorm:"index:idx_email,unique"`
	Password  string
	Active    bool
}

var (
	ErrDuplicateEmail = errors.New("duplicate email")
)
