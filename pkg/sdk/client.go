package sdk

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
)

type Sdk struct {
	Client         *http.Client
	ApiUrl         string
	OrganizationId string
}

type RunResponse struct {
	Runs []Run `json:"runs"`
}

type Run struct {
	Id          string `json:"id"`
	Status      string `json:"status"`
	WorkspaceId string `json:"workspace_id"`
}

type WorkspaceResponse struct {
	Workspace Workspace `json:"workspace"`
}

type Workspace struct {
	Id     string `json:"id"`
	Name   string `json:"name"`
	Locked bool   `json:"locked"`
}

func (s *Sdk) GetRuns(agentId string) (*RunResponse, error) {
	runsUrl := fmt.Sprintf("%sorgs/%s/agents/%s/runs", s.ApiUrl, s.OrganizationId, agentId)
	res, err := s.Client.Get(runsUrl)

	b, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	var data RunResponse
	if err = json.Unmarshal(b, &data); err != nil {
		return nil, err
	}
	return &data, nil
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

func (s *Sdk) ShipLogs(runId string, logs string) error {
	logsUrl := fmt.Sprintf("%sorgs/%s/runs/%s/logs", s.ApiUrl, s.OrganizationId, runId)
	reader := strings.NewReader(logs)
	_, err := s.Client.Post(logsUrl, "", reader)
	return err
}

func (s *Sdk) UpdateRun(runId string, data map[string]interface{}) error {
	runUrl := fmt.Sprintf("%sorgs/%s/runs/%s", s.ApiUrl, s.OrganizationId, runId)
	b := new(bytes.Buffer)
	if err := json.NewEncoder(b).Encode(data); err != nil {
		return err
	}
	res, err := s.Client.Post(runUrl, "application/json", b)
	fmt.Println(res)
	return err
}
