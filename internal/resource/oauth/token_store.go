package oauth

import (
	"context"
	"encoding/json"
	"github.com/go-oauth2/oauth2/v4"
	"github.com/go-oauth2/oauth2/v4/models"
	"gorm.io/gorm"
	"time"
)

type TokenStore struct {
	Db *gorm.DB
}

func NewTokenStore(db *gorm.DB) (*TokenStore, error) {
	return &TokenStore{Db: db}, nil
}

// create and store the new token information
func (ts *TokenStore) Create(ctx context.Context, info oauth2.TokenInfo) error {
	buf, err := json.Marshal(info)
	if err != nil {
		return err
	}

	token := &OauthToken{
		Data:      buf,
		CreatedAt: time.Now(),
	}

	if code := info.GetCode(); code != "" {
		token.Code = code
		token.ExpiresAt = info.GetCodeCreateAt().Add(info.GetCodeExpiresIn())
	} else {
		token.Access = info.GetAccess()
		token.ExpiresAt = info.GetAccessCreateAt().Add(info.GetAccessExpiresIn())

		if refresh := info.GetRefresh(); refresh != "" {
			token.Refresh = info.GetRefresh()
			token.ExpiresAt = info.GetRefreshCreateAt().Add(info.GetRefreshExpiresIn())
		}
	}

	result := ts.Db.Create(&token)
	return result.Error
}

// delete the authorization code
func (ts *TokenStore) RemoveByCode(ctx context.Context, code string) error {
	result := ts.Db.Where("code = ?", code).Delete(&OauthToken{})
	return result.Error
}

// use the access token to delete the token information
func (ts *TokenStore) RemoveByAccess(ctx context.Context, access string) error {
	result := ts.Db.Where("access = ?", access).Delete(&OauthToken{})
	return result.Error
}

// use the refresh token to delete the token information
func (ts *TokenStore) RemoveByRefresh(ctx context.Context, refresh string) error {
	result := ts.Db.Where("refresh = ?", refresh).Delete(&OauthToken{})
	return result.Error
}

// use the authorization code for token information data
func (ts *TokenStore) GetByCode(ctx context.Context, code string) (oauth2.TokenInfo, error) {
	token := &OauthToken{}
	result := ts.Db.Where("code = ?", code).First(&token)
	if result.Error != nil {
		return nil, result.Error
	}
	return ts.toToken(token.Data)
}

// use the access token for token information data
func (ts *TokenStore) GetByAccess(ctx context.Context, access string) (oauth2.TokenInfo, error) {
	token := &OauthToken{}
	result := ts.Db.Where("access = ?", access).First(&token)
	if result.Error != nil {
		return nil, result.Error
	}
	return ts.toToken(token.Data)
}

// use the refresh token for token information data
func (ts *TokenStore) GetByRefresh(ctx context.Context, refresh string) (oauth2.TokenInfo, error) {
	token := &OauthToken{}
	result := ts.Db.Where("refresh = ?", refresh).First(&token)
	if result.Error != nil {
		return nil, result.Error
	}
	return ts.toToken(token.Data)
}

func (ts *TokenStore) toToken(data []byte) (oauth2.TokenInfo, error) {
	var tm models.Token
	err := json.Unmarshal(data, &tm)
	return &tm, err
}
