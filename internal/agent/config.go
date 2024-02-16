package agent

import "strings"

type Config struct {
	Runner  *RunnerConfig `yaml:"runner,omitempty"`
	AgentId string        `yaml:"agentId"`
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

func (c *Config) GetNamespace() string {
	if c.Runner != nil && c.Runner.Namespace != "" {
		return c.Runner.Namespace
	}
	return "default"
}

func (c *Config) GetAgentId() string {
	return c.AgentId
}
