package models

import "gorm.io/gorm"

func Setup(db *gorm.DB) error {
	return db.AutoMigrate(
		&Workspace{},
		&Organization{},
		&OauthClient{},
		&OauthToken{},
		&Run{},
	)
}
