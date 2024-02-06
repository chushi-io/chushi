package vcs_connection

import (
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
	Provider  string              `json:"provider"`
	Github    GithubConnection    `gorm:"embedded;embeddedPrefix:github_"`
	Gitlab    GitlabConnection    `gorm:"embedded;embeddedPrefix:gitlab_"`
	Bitbucket BitbucketConnection `gorm:"embedded;embeddedPrefix:bitbucket_"`
	Git       GitConnection       `gorm:"embedded;embeddedPrefix:git_"`
}

type GitConnection struct {
}

type GithubConnection struct {
}

type GitlabConnection struct {
}

type BitbucketConnection struct {
}
