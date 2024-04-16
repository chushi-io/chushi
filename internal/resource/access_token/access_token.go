package access_token

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
	"time"
)

type AccessToken struct {
	Id        uuid.UUID  `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	Name      string     `json:"name"`
	Token     string     `json:"-"`
	UserId    uuid.UUID  `json:"-"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt *time.Time `json:"updated_at"`
	LastSeen  *time.Time `json:"last_seen"`
	DeletedAt *time.Time `json:"deleted_at"`
	ExpiresAt *time.Time `json:"expires_at"`
}

type Repository interface {
	List(userId uuid.UUID) ([]AccessToken, error)
	FindById(tokenId uuid.UUID) (*AccessToken, error)
	FindByToken(token string) (*AccessToken, error)
	Create(token *AccessToken) (*AccessToken, error)
	Update(token *AccessToken) (*AccessToken, error)
	Delete(tokenId uuid.UUID) error
}

type repositoryImpl struct {
	Db *gorm.DB
}

func New(db *gorm.DB) Repository {
	return &repositoryImpl{Db: db}
}

func (r repositoryImpl) List(userId uuid.UUID) ([]AccessToken, error) {
	var tokens []AccessToken
	if result := r.Db.Where("user_id = ?", userId).Find(&tokens); result.Error != nil {
		return nil, result.Error
	}
	return tokens, nil
}

func (r repositoryImpl) FindById(tokenId uuid.UUID) (*AccessToken, error) {
	var token AccessToken
	if result := r.Db.Where("id = ?", tokenId).First(&token); result.Error != nil {
		return nil, result.Error
	}
	return &token, nil
}

func (r repositoryImpl) FindByToken(tokenValue string) (*AccessToken, error) {
	var token AccessToken
	if result := r.Db.Where("token = ?", tokenValue).First(&token); result.Error != nil {
		return nil, result.Error
	}
	return &token, nil
}

func (r repositoryImpl) Create(token *AccessToken) (*AccessToken, error) {
	// For now, we'll just generate UUIDs for our access tokens
	token.Token = uuid.New().String()
	result := r.Db.Create(token)
	return token, result.Error
}

func (r repositoryImpl) Update(token *AccessToken) (*AccessToken, error) {
	return nil, nil
}

func (r repositoryImpl) Delete(tokenId uuid.UUID) error {
	return nil
}
