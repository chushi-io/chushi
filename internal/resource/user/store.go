package user

import (
	"context"
	"fmt"
	"github.com/volatiletech/authboss/v3"
	"gorm.io/gorm"
)

type Store struct {
	Database *gorm.DB
}

func NewStore(db *gorm.DB) *Store {
	return &Store{Database: db}
}
func (s *Store) Save(_ context.Context, user authboss.User) error {
	u := user.(*User)
	fmt.Println("saving user:", u.Email)
	// Save to the database
	return nil
}

func (s *Store) Load(_ context.Context, key string) (user authboss.User, err error) {
	return &User{}, nil
}

func (s *Store) New(_ context.Context) authboss.User {
	return &User{}
}

func (s *Store) Create(_ context.Context, user authboss.User) error {
	return nil
}

func (s *Store) LoadByConfirmSelector(_ context.Context, selector string) (user authboss.ConfirmableUser, err error) {
	return &User{}, nil
}

func (s *Store) LoadByRecoverSelector(_ context.Context, selector string) (user authboss.RecoverableUser, err error) {
	return &User{}, nil
}

func (s *Store) AddRememberToken(_ context.Context, pid, token string) error {
	return nil
}

func (s *Store) DelRememberTokens(_ context.Context, pid string) error {
	return nil
}

func (s *Store) UseRememberToken(_ context.Context, token string) error {
	return nil
}

func (s *Store) NewFromOAuth2(_ context.Context, provider string, details map[string]string) (authboss.OAuth2User, error) {
	return &User{}, nil
}

func (s *Store) SaveOAuth2(_ context.Context, user authboss.OAuth2User) error {
	return nil
}
