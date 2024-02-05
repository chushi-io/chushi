package sdk

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/google/go-querystring/query"
	"github.com/google/uuid"
	"io"
	"strings"
	"time"
)

type Run struct {
	Id               string     `json:"id"`
	Status           string     `json:"status"`
	WorkspaceId      string     `json:"workspace_id"`
	OrganizationId   string     `json:"organization_id"`
	Operation        string     `json:"operation"`
	Add              int        `json:"add"`
	Change           int        `json:"change"`
	Destroy          int        `json:"destroy"`
	ManagedResources int        `json:"managed_resources"`
	CreatedAt        time.Time  `json:"created_at"`
	UpdatedAt        time.Time  `json:"updated_at"`
	CompletedAt      *time.Time `json:"completed_at"`
	AgentId          *uuid.UUID `json:"agent_id,omitempty"`
}

type Runs struct {
	sdk *Sdk
}

type ListRunsParams struct {
	AgentId     string     `json:"agent_id,omitempty" url:"-"`
	Status      string     `json:"status,omitempty" url:"status,omitempty"`
	WorkspaceId *uuid.UUID `json:"workspace_id,omitempty" url:"-"`
}

type ListRunsResponse struct {
	Runs []Run `json:"runs"`
}

func (r *Runs) List(params *ListRunsParams) (*ListRunsResponse, error) {
	var runsUrl string
	if params.AgentId != "" {
		runsUrl = fmt.Sprintf("%sorgs/%s/agents/%s/runs", r.sdk.ApiUrl, r.sdk.OrganizationId, params.AgentId)
	} else if params.WorkspaceId != nil {
		runsUrl = fmt.Sprintf("%sorgs/%s/workspaces/%s/runs", r.sdk.ApiUrl, r.sdk.OrganizationId, params.WorkspaceId)
	} else {
		runsUrl = fmt.Sprintf("%sorgs/%s/runs", r.sdk.ApiUrl, r.sdk.OrganizationId)
	}

	fmt.Println(runsUrl)
	v, _ := query.Values(params)
	fullUrl := strings.Join([]string{runsUrl, v.Encode()}, "?")
	res, err := r.sdk.Client.Get(fullUrl)

	b, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	var data ListRunsResponse
	if err = json.Unmarshal(b, &data); err != nil {
		return nil, err
	}
	return &data, nil
}

func (r *Runs) UploadLogs(runId string, logs string) error {
	logsUrl := fmt.Sprintf("%sorgs/%s/runs/%s/logs", r.sdk.ApiUrl, r.sdk.OrganizationId, runId)
	reader := strings.NewReader(logs)
	_, err := r.sdk.Client.Post(logsUrl, "", reader)
	return err
}

type UpdateRunParams struct {
	RunId            string
	Status           string `json:"status,omitempty"`
	Add              int    `json:"add,omitempty"`
	Change           int    `json:"change,omitempty"`
	Destroy          int    `json:"destroy,omitempty"`
	ManagedResources int    `json:"managed_resources,omitempty"`
}

type UpdateRunResponse struct {
	Run Run `json:"run"`
}

func (r *Runs) Update(params *UpdateRunParams) (*UpdateRunResponse, error) {
	runUrl := fmt.Sprintf("%sorgs/%s/runs/%s", r.sdk.ApiUrl, r.sdk.OrganizationId, params.RunId)
	b := new(bytes.Buffer)
	if err := json.NewEncoder(b).Encode(params); err != nil {
		return nil, err
	}

	res, err := r.sdk.Client.Post(runUrl, "application/json", b)
	if err != nil {
		return nil, err
	}
	buf := new(bytes.Buffer)
	buf.ReadFrom(res.Body)
	var response UpdateRunResponse
	err = json.Unmarshal(buf.Bytes(), &response)
	return &response, err
}
