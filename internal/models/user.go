package models

import "errors"

type User struct {
	Base
	Email    string `gorm:"index:idx_email,unique"`
	Password string
	Active   bool
}

var (
	ErrDuplicateEmail = errors.New("duplicate email")
)
