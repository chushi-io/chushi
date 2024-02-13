package organization

import (
	"context"
	"errors"
	"github.com/volatiletech/authboss/v3"
	"gorm.io/gorm"
)

type UserStore struct {
	Database *gorm.DB
}

func NewUserStore(db *gorm.DB) *UserStore {
	return &UserStore{Database: db}
}

func (s *UserStore) Save(_ context.Context, user authboss.User) error {
	u := user.(*User)
	result := s.Database.Save(&u)
	// Save to the database
	return result.Error
}

func (s *UserStore) Load(_ context.Context, key string) (user authboss.User, err error) {
	var u User
	provider, uid, err := authboss.ParseOAuth2PID(key)
	if err == nil {
		result := s.Database.Where("oauth2_provider = ?", provider).Where("oauth2_uid = ?", uid).First(&u)
		if result.Error != nil {
			if errors.Is(result.Error, gorm.ErrRecordNotFound) {
				return nil, authboss.ErrUserNotFound
			}
			return nil, result.Error
		}
		return &u, nil
	}

	result := s.Database.Where("email = ?", key).First(&u)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, authboss.ErrUserNotFound
		}
		return nil, result.Error
	}

	return &u, nil
}

func (s *UserStore) New(_ context.Context) authboss.User {
	return &User{}
}

func (s *UserStore) Create(_ context.Context, user authboss.User) error {
	// We'd probably want to check if the user already exists
	u := user.(*User)
	result := s.Database.Save(&u)
	// Save to the database
	return result.Error
}

func (s *UserStore) LoadByConfirmSelector(_ context.Context, selector string) (user authboss.ConfirmableUser, err error) {
	var res User
	result := s.Database.Where("confirm_selector = ?", selector).First(&res)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, authboss.ErrUserNotFound
		}
		return nil, result.Error
	}

	return user, authboss.ErrUserNotFound
}

func (s *UserStore) LoadByRecoverSelector(_ context.Context, selector string) (user authboss.RecoverableUser, err error) {
	var res User
	result := s.Database.Where("recover_selector = ?", selector).First(&res)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, authboss.ErrUserNotFound
		}
		return nil, result.Error
	}

	return user, authboss.ErrUserNotFound
}

func (s *UserStore) AddRememberToken(_ context.Context, pid, token string) error {
	return nil
}

func (s *UserStore) DelRememberTokens(_ context.Context, pid string) error {
	return nil
}

func (s *UserStore) UseRememberToken(_ context.Context, token string) error {
	return nil
}

func (s *UserStore) NewFromOAuth2(_ context.Context, provider string, details map[string]string) (authboss.OAuth2User, error) {
	return &User{}, nil
}

func (s *UserStore) SaveOAuth2(_ context.Context, user authboss.OAuth2User) error {
	return nil
}
