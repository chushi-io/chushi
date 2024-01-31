package models

import (
	"context"
	"github.com/go-oauth2/oauth2/v4"
	"gorm.io/gorm"
)

type ClientStore struct {
	Db *gorm.DB
}

type ClientStoreItem struct {
	ID     string `db:"id"`
	Secret string `db:"secret"`
	Domain string `db:"domain"`
	Data   []byte `db:"data"`
}

func NewClientStore(db *gorm.DB) *ClientStore {
	return &ClientStore{Db: db}
}

func (csi ClientStoreItem) GetID() string {
	return csi.ID
}

func (csi ClientStoreItem) GetSecret() string {
	return csi.Secret
}

func (csi ClientStoreItem) GetDomain() string {
	return ""
}

func (csi ClientStoreItem) IsPublic() bool {
	return false
}

func (csi ClientStoreItem) GetUserID() string {
	return ""
}

func (c *ClientStore) GetByID(ctx context.Context, id string) (oauth2.ClientInfo, error) {
	return ClientStoreItem{}, nil
}

func (s *ClientStore) Create(info oauth2.ClientInfo) error {
	return nil
}

type TokenStore struct {
	Db *gorm.DB
}

type TokenStoreItem struct {
	gorm.Model

	ExpiredAt int64
	Code      string `gorm:"type:varchar(512)"`
	Access    string `gorm:"type:varchar(512)"`
	Refresh   string `gorm:"type:varchar(512)"`
	Data      string `gorm:"type:text"`
}

func NewTokenStore(db *gorm.DB) (*TokenStore, error) {
	return &TokenStore{Db: db}, nil
}

// create and store the new token information
func (ts *TokenStore) Create(ctx context.Context, info oauth2.TokenInfo) error {
	return nil
}

// delete the authorization code
func (Ts *TokenStore) RemoveByCode(ctx context.Context, code string) error {
	return nil
}

// use the access token to delete the token information
func (ts *TokenStore) RemoveByAccess(ctx context.Context, access string) error {
	return nil
}

// use the refresh token to delete the token information
func (ts *TokenStore) RemoveByRefresh(ctx context.Context, refresh string) error {
	return nil
}

// use the authorization code for token information data
func (ts *TokenStore) GetByCode(ctx context.Context, code string) (oauth2.TokenInfo, error) {
	return nil, nil
}

// use the access token for token information data
func (ts *TokenStore) GetByAccess(ctx context.Context, access string) (oauth2.TokenInfo, error) {
	return nil, nil
}

// use the refresh token for token information data
func (ts *TokenStore) GetByRefresh(ctx context.Context, refresh string) (oauth2.TokenInfo, error) {
	return nil, nil
}
