package sdk

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type Sdk struct {
	Client         *http.Client
	ApiUrl         string
	TokenUrl       string
	OrganizationId string

	runs   *Runs
	tokens *Tokens
}

func New() {

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

type WorkspaceResponse struct {
	Workspace Workspace `json:"workspace"`
}

type Workspace struct {
	Id     string       `json:"id"`
	Name   string       `json:"name"`
	Locked bool         `json:"locked"`
	Vcs    WorkspaceVcs `json:"vcs"`
}

type WorkspaceVcs struct {
	Source           string   `json:"source"`
	Branch           string   `json:"branch"`
	Patterns         []string `json:"patterns,omitempty"`
	Prefixes         []string `json:"prefixes,omitempty"`
	WorkingDirectory string   `json:"working_directory,omitempty"`
}

func (s *Sdk) GetWorkspace(workspaceId string) (*WorkspaceResponse, error) {
	workspaceUrl := fmt.Sprintf("%sorgs/%s/workspaces/%s", s.ApiUrl, s.OrganizationId, workspaceId)
	res, err := s.Client.Get(workspaceUrl)
	if err != nil {
		return nil, err
	}

	b, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	var workspaceResponse WorkspaceResponse
	if err := json.Unmarshal(b, &workspaceResponse); err != nil {
		return nil, err
	}
	return &workspaceResponse, nil
}
