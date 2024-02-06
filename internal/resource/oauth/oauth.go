package oauth

import (
	"gorm.io/gorm"
	"time"
)

type OauthClient struct {
	ID        string `db:"id"`
	Secret    string `gorm:"type:varchar(512)"`
	Domain    string `gorm:"type:varchar(512)"`
	Data      string `gorm:"type:text"`
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt gorm.DeletedAt `gorm:"index"`
}

type OauthToken struct {
	gorm.Model

	CreatedAt time.Time `json:"created_at"`
	ExpiresAt time.Time `json:"expires_at"`

	Code    string `gorm:"type:varchar(512)"`
	Access  string `gorm:"type:varchar(512)"`
	Refresh string `gorm:"type:varchar(512)"`
	Data    []byte `gorm:"type:text"`
}
