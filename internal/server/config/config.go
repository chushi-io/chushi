package config

import "github.com/spf13/viper"

type Config struct {
	DatabaseUri string `mapstructure:"database_uri"`
}

// Load will parse any environment variables in .env
// We may support additional configuration formats
// at some point in the future
func Load() (*Config, error) {
	v := viper.New()
	v.SetConfigFile(".env")
	v.ReadInConfig()

	v.BindEnv("database_uri")

	config := &Config{}
	if err := v.Unmarshal(config); err != nil {
		return nil, err
	}
	return config, nil
}
