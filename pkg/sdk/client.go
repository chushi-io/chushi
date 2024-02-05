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
	OrganizationId string

	runs *Runs
}

func New() {

}

func (s *Sdk) Runs() *Runs {
	if s.runs == nil {
		s.runs = &Runs{sdk: s}
	}
	return s.runs
}

type WorkspaceResponse struct {
	Workspace Workspace `json:"workspace"`
}

type Workspace struct {
	Id     string `json:"id"`
	Name   string `json:"name"`
	Locked bool   `json:"locked"`
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
