package github

import "github.com/google/go-github/v61/github"

type Integration struct {
	Client github.Client
}

func NewForClient(client github.Client) *Integration {
	return &Integration{Client: client}
}

func (i *Integration) CreateCommitStatus() {

}

func (i *Integration) UpdateCommitStatus() {

}

func (i *Integration) PostPlanToPullRequest() {

}
