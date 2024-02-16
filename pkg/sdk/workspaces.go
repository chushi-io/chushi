package sdk

import (
	"fmt"
	"github.com/google/uuid"
)

type Workspaces struct {
	sdk *Sdk
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

type CredentialsResponse struct {
	Credentials Credentials `json:"credentials"`
}

type Credentials struct {
	Token string `json:"token"`
}

func (s *Sdk) GetWorkspace(workspaceId string) (*WorkspaceResponse, error) {
	workspaceUrl := s.GetOrganizationUrl("workspaces/" + workspaceId)
	var response WorkspaceResponse
	_, err := s.Client.Get(workspaceUrl).ReceiveSuccess(&response)
	if err != nil {
		return nil, err
	}
	return &response, nil
}

func (w *Workspaces) GetConnectionCredentials(connectionId uuid.UUID) (*CredentialsResponse, error) {
	credentialsUrl := fmt.Sprintf("vcs_connections/%s/credentials", connectionId)
	var response CredentialsResponse
	_, err := w.sdk.Client.Get(credentialsUrl).ReceiveSuccess(&response)
	if err != nil {
		return nil, err
	}
	return &response, nil
}
