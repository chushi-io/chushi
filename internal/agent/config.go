package agent

import "strings"

type Config struct {
	Runner  *RunnerConfig `yaml:"runner,omitempty"`
	Server  *ServerConfig `yaml:"server,omitempty"`
	AgentId string        `yaml:"agentId"`
}

type ServerConfig struct {
	ApiUrl   string `yaml:"apiUrl,omitempty"`
	TokenUrl string `yaml:"tokenUrl,omitempty"`
}

type RunnerConfig struct {
	Image     string `yaml:"image,omitempty"`
	Version   string `yaml:"version,omitempty"`
	Namespace string `yaml:"namespace,omitempty"`
}

func LoadConfig() (*Config, error) {
	return &Config{}, nil
}

func (c *Config) GetImage() string {
	image := "ghcr.io/chushi-io/chushi"
	if c.Runner != nil && c.Runner.Image != "" {
		image = c.Runner.Image
	}

	version := "latest"
	if c.Runner != nil && c.Runner.Version != "" {
		version = c.Runner.Version
	}

	return strings.Join([]string{image, version}, ":")
}

func (c *Config) GetApiUrl() string {
	if c.Server != nil && c.Server.ApiUrl != "" {
		return c.Server.ApiUrl
	}
	return "https://chushi.io/api/v1"
}

func (c *Config) GetNamespace() string {
	if c.Runner != nil && c.Runner.Namespace != "" {
		return c.Runner.Namespace
	}
	return "default"
}

func (c *Config) GetAgentId() string {
	return c.AgentId
}
