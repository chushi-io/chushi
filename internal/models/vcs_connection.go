package models

type VcsConnection struct {
	Base
	Name string `json:"name"`
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
