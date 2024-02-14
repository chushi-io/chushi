package vcs_connection

import (
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/google/uuid"
	"time"
)

type VcsConnection struct {
	ID        uuid.UUID  `gorm:"type:uuid;default:gen_random_uuid()" json:"id"`
	CreatedAt time.Time  `json:"created_at"`
	UpdatedAt time.Time  `json:"updated_at"`
	DeletedAt *time.Time `sql:"index" json:"deleted_at"`
	Name      string     `json:"name"`
	// One of github, gitlab, bitbucket, or git
	Provider       string                    `json:"provider"`
	Github         GithubConnection          `gorm:"embedded;embeddedPrefix:github_" json:"github,omitempty"`
	Gitlab         GitlabConnection          `gorm:"embedded;embeddedPrefix:gitlab_" json:"gitlab,omitempty"`
	Bitbucket      BitbucketConnection       `gorm:"embedded;embeddedPrefix:bitbucket_" json:"bitbucket,omitempty"`
	Git            GitConnection             `gorm:"embedded;embeddedPrefix:git_" json:"git,omitempty"`
	OrganizationID uuid.UUID                 `json:"organization_id"`
	Organization   organization.Organization `json:"-"`
}

type GitConnection struct {
}

type GithubConnection struct {
	Type                   string `json:"type"`
	PersonalAccessToken    string `json:"-"`
	ApplicationId          string `json:"application_id,omitempty"`
	ApplicationSecret      string `json:"-"`
	OauthApplicationId     string `json:"oauth_application_id,omitempty"`
	OauthApplicationSecret string `json:"-"`
}

type GitlabConnection struct {
}

type BitbucketConnection struct {
}
