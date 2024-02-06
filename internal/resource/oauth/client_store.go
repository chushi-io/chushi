package oauth

import (
	"context"
	"encoding/json"
	"github.com/go-oauth2/oauth2/v4"
	"github.com/go-oauth2/oauth2/v4/models"
	"gorm.io/gorm"
)

type ClientStore struct {
	Db *gorm.DB
}

func NewClientStore(db *gorm.DB) *ClientStore {
	return &ClientStore{Db: db}
}

func (cs *ClientStore) toClientInfo(data []byte) (oauth2.ClientInfo, error) {
	var cm models.Client
	err := json.Unmarshal(data, &cm)
	return &cm, err
}

func (c *ClientStore) GetByID(ctx context.Context, id string) (oauth2.ClientInfo, error) {
	if id == "" {
		return nil, nil
	}

	var item OauthClient
	result := c.Db.Where("id = ?", id).First(&item)
	if result.Error != nil {
		return nil, result.Error
	}

	return c.toClientInfo([]byte(item.Data))
}

func (s *ClientStore) Create(info oauth2.ClientInfo) error {
	data, err := json.Marshal(info)
	if err != nil {
		return err
	}

	item := &OauthClient{
		Data:   string(data),
		ID:     info.GetID(),
		Secret: info.GetSecret(),
		Domain: info.GetDomain(),
	}
	if result := s.Db.Create(&item); result.Error != nil {
		return result.Error
	}
	return nil
}
