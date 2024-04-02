package config

import "github.com/spf13/viper"

type Config struct {
	DatabaseUri   string `mapstructure:"database_uri"`
	JwtSecretKey  string `mapstructure:"jwt_secret_key"`
	SessionSecret string `mapstructure:"session_secret"`
	CookieSecret  string `mapstructure:"cookie_secret"`
	IssuerUrl     string `mapstructure:"issuer_url"`
}

// Load will parse any environment variables in .env
// We may support additional configuration formats
// at some point in the future
func Load() (*Config, error) {
	v := viper.New()
	v.SetConfigFile(".env")
	v.ReadInConfig()

	v.BindEnv("database_uri")
	v.BindEnv("jwt_secret_key")
	v.BindEnv("session_secret")
	v.BindEnv("cookie_secret")
	v.BindEnv("issuer_url")

	config := &Config{}
	if err := v.Unmarshal(config); err != nil {
		return nil, err
	}
	return config, nil
}
