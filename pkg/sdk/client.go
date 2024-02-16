package sdk

import (
	"context"
	"fmt"
	"github.com/dghubble/sling"
	"github.com/google/uuid"
	"golang.org/x/oauth2/clientcredentials"
	"net/http"
	"os"
)

type Sdk struct {
	Client         *sling.Sling
	TokenUrl       string
	OrganizationId uuid.UUID

	runs       *Runs
	tokens     *Tokens
	workspaces *Workspaces
}

const (
	ClientIdEnvVar       = "CHUSHI_CLIENT_ID"
	ClientSecretEnvVar   = "CHUSHI_CLIENT_SECRET"
	AccessTokenEnvVar    = "CHUSHI_ACCESS_TOKEN"
	UrlEnvVar            = "CHUSHI_URL"
	OrganizationIdEnvVar = "CHUSHI_ORGANIZATION_ID"
)

func New() *Sdk {
	baseUrl := "https://chushi.io"
	if url := os.Getenv(UrlEnvVar); url != "" {
		baseUrl = url
	}

	client := sling.New().Base(baseUrl)
	sdk := &Sdk{Client: client}

	if organizationId := os.Getenv(OrganizationIdEnvVar); organizationId != "" {
		if uid, err := uuid.Parse(organizationId); err == nil {
			sdk.OrganizationId = uid
		}
	}

	// Figure out our client auth mechanism
	if clientSecret := os.Getenv(ClientSecretEnvVar); clientSecret != "" {
		sdk.WithClientCredentials(
			os.Getenv(ClientIdEnvVar),
			clientSecret,
			fmt.Sprintf("%s/oauth/v1/token", baseUrl),
		)
		return sdk
	}

	if token := os.Getenv(AccessTokenEnvVar); token != "" {
		sdk = sdk.WithAccessToken(token)
	}
	return sdk
}

func (s *Sdk) WithBaseUrl(baseUrl string) *Sdk {
	s.Client.Base(baseUrl)
	return s
}

func (s *Sdk) WithClient(client *http.Client) *Sdk {
	s.Client.Client(client)
	return s
}

func (s *Sdk) WithAccessToken(accessToken string) *Sdk {
	s.Client.Set("Authorization", "Bearer "+accessToken)
	return s
}

func (s *Sdk) WithClientCredentials(clientId string, clientSecret string, tokenUrl string) *Sdk {
	s.Client.Client((&clientcredentials.Config{
		ClientID:     clientId,
		ClientSecret: clientSecret,
		TokenURL:     tokenUrl,
	}).Client(context.TODO()))
	return s
}

func (s *Sdk) WithOrganizationId(organizationId uuid.UUID) *Sdk {
	s.OrganizationId = organizationId
	return s
}

func (s *Sdk) GetOrganizationUrl(path string) string {
	return fmt.Sprintf("/api/v1/orgs/%s/%s", s.OrganizationId, path)
}

func (s *Sdk) Runs() *Runs {
	if s.runs == nil {
		s.runs = &Runs{sdk: s}
	}
	return s.runs
}

func (s *Sdk) Tokens() *Tokens {
	if s.tokens == nil {
		s.tokens = &Tokens{sdk: s}
	}
	return s.tokens
}

func (s *Sdk) Workspaces() *Workspaces {
	if s.workspaces == nil {
		s.workspaces = &Workspaces{sdk: s}
	}
	return s.workspaces
}
