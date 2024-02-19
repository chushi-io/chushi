package organization

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
	Password  string     `gorm:"column:password"`
	Active    bool       `gorm:"column:active"`

	// Confirm
	ConfirmSelector string `gorm:"column:confirm_selector"`
	ConfirmVerifier string `gorm:"column:confirm_verifier"`
	Confirmed       bool   `gorm:"column:confirmed"`

	// Lock
	AttemptCount int       `gorm:"column:attempt_count"`
	LastAttempt  time.Time `gorm:"column:last_attempt"`
	Locked       time.Time `gorm:"column:locked"`

	// Recover
	RecoverSelector    string    `gorm:"column:recover_selector"`
	RecoverVerifier    string    `gorm:"column:recover_verifier"`
	RecoverTokenExpiry time.Time `gorm:"column:recover_token_expiry"`

	// OAuth2
	OAuth2UID          string    `gorm:"column:oauth2_uid"`
	OAuth2Provider     string    `gorm:"column:oauth2_provider"`
	OAuth2AccessToken  string    `gorm:"column:oauth2_access_token"`
	OAuth2RefreshToken string    `gorm:"column:oauth2_refresh_token"`
	OAuth2Expiry       time.Time `gorm:"column:oauth2_expiry"`

	// 2fa
	TOTPSecretKey      string `gorm:"column:totp_secret_key"`
	SMSPhoneNumber     string `gorm:"column:sms_phone_number"`
	SMSSeedPhoneNumber string `gorm:"column:sms_seed_phone_number"`
	RecoveryCodes      string `gorm:"column:recovery_codes"`

	Organizations []*Organization `gorm:"many2many:organization_users;"`
}

var (
	ErrDuplicateEmail = errors.New("duplicate email")
)

func (u *User) PutPID(pid string)                         { u.Email = pid }
func (u *User) PutPassword(password string)               { u.Password = password }
func (u *User) PutEmail(email string)                     { u.Email = email }
func (u *User) PutConfirmed(confirmed bool)               { u.Confirmed = confirmed }
func (u *User) PutConfirmSelector(confirmSelector string) { u.ConfirmSelector = confirmSelector }

// PutConfirmVerifier into user
func (u *User) PutConfirmVerifier(confirmVerifier string) { u.ConfirmVerifier = confirmVerifier }

// PutLocked into user
func (u *User) PutLocked(locked time.Time) { u.Locked = locked }

// PutAttemptCount into user
func (u *User) PutAttemptCount(attempts int) { u.AttemptCount = attempts }

// PutLastAttempt into user
func (u *User) PutLastAttempt(last time.Time) { u.LastAttempt = last }

// PutRecoverSelector into user
func (u *User) PutRecoverSelector(token string) { u.RecoverSelector = token }

// PutRecoverVerifier into user
func (u *User) PutRecoverVerifier(token string) { u.RecoverVerifier = token }

// PutRecoverExpiry into user
func (u *User) PutRecoverExpiry(expiry time.Time) { u.RecoverTokenExpiry = expiry }

// PutTOTPSecretKey into user
func (u *User) PutTOTPSecretKey(key string) { u.TOTPSecretKey = key }

// PutSMSPhoneNumber into user
func (u *User) PutSMSPhoneNumber(key string) { u.SMSPhoneNumber = key }

// PutRecoveryCodes into user
func (u *User) PutRecoveryCodes(key string) { u.RecoveryCodes = key }

// PutOAuth2UID into user
func (u *User) PutOAuth2UID(uid string) { u.OAuth2UID = uid }

// PutOAuth2Provider into user
func (u *User) PutOAuth2Provider(provider string) { u.OAuth2Provider = provider }

// PutOAuth2AccessToken into user
func (u *User) PutOAuth2AccessToken(token string) { u.OAuth2AccessToken = token }

// PutOAuth2RefreshToken into user
func (u *User) PutOAuth2RefreshToken(refreshToken string) { u.OAuth2RefreshToken = refreshToken }

// PutOAuth2Expiry into user
func (u *User) PutOAuth2Expiry(expiry time.Time) { u.OAuth2Expiry = expiry }

func (u *User) PutArbitrary(values map[string]string) {

}

// GetPID from user
func (u User) GetPID() string { return u.Email }

// GetPassword from user
func (u User) GetPassword() string { return u.Password }

// GetEmail from user
func (u User) GetEmail() string { return u.Email }

// GetConfirmed from user
func (u User) GetConfirmed() bool { return u.Confirmed }

// GetConfirmSelector from user
func (u User) GetConfirmSelector() string { return u.ConfirmSelector }

// GetConfirmVerifier from user
func (u User) GetConfirmVerifier() string { return u.ConfirmVerifier }

// GetLocked from user
func (u User) GetLocked() time.Time { return u.Locked }

// GetAttemptCount from user
func (u User) GetAttemptCount() int { return u.AttemptCount }

// GetLastAttempt from user
func (u User) GetLastAttempt() time.Time { return u.LastAttempt }

// GetRecoverSelector from user
func (u User) GetRecoverSelector() string { return u.RecoverSelector }

// GetRecoverVerifier from user
func (u User) GetRecoverVerifier() string { return u.RecoverVerifier }

// GetRecoverExpiry from user
func (u User) GetRecoverExpiry() time.Time { return u.RecoverTokenExpiry }

// GetTOTPSecretKey from user
func (u User) GetTOTPSecretKey() string { return u.TOTPSecretKey }

// GetSMSPhoneNumber from user
func (u User) GetSMSPhoneNumber() string { return u.SMSPhoneNumber }

// GetSMSPhoneNumberSeed from user
func (u User) GetSMSPhoneNumberSeed() string { return u.SMSSeedPhoneNumber }

// GetRecoveryCodes from user
func (u User) GetRecoveryCodes() string { return u.RecoveryCodes }

// IsOAuth2User returns true if the user was created with oauth2
func (u User) IsOAuth2User() bool { return len(u.OAuth2UID) != 0 }

// GetOAuth2UID from user
func (u User) GetOAuth2UID() (uid string) { return u.OAuth2UID }

// GetOAuth2Provider from user
func (u User) GetOAuth2Provider() (provider string) { return u.OAuth2Provider }

// GetOAuth2AccessToken from user
func (u User) GetOAuth2AccessToken() (token string) { return u.OAuth2AccessToken }

// GetOAuth2RefreshToken from user
func (u User) GetOAuth2RefreshToken() (refreshToken string) { return u.OAuth2RefreshToken }

// GetOAuth2Expiry from user
func (u User) GetOAuth2Expiry() (expiry time.Time) { return u.OAuth2Expiry }

// GetArbitrary from user
func (u User) GetArbitrary() map[string]string {
	return map[string]string{
		"id": u.ID.String(),
	}
}
