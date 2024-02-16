package sdk

import (
	"bytes"
	"fmt"
	"github.com/google/uuid"
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
		runsUrl = fmt.Sprintf("agents/%s/runs", params.AgentId)
	} else if params.WorkspaceId != nil {
		runsUrl = fmt.Sprintf("workspaces/%s/runs", params.WorkspaceId)
	} else {
		runsUrl = "runs"
	}

	fullUrl := r.sdk.GetOrganizationUrl(runsUrl)
	var data ListRunsResponse
	_, err := r.sdk.Client.Get(fullUrl).ReceiveSuccess(&data)
	if err != nil {
		return nil, err
	}
	return &data, nil
}

func (r *Runs) UploadLogs(runId string, logs string) error {
	logsUrl := r.sdk.GetOrganizationUrl(fmt.Sprintf("runs/%s/logs", runId))
	reader := strings.NewReader(logs)
	req, err := r.sdk.Client.Body(reader).Post(logsUrl).Request()
	if err != nil {
		return err
	}
	_, err = r.sdk.Client.Do(req, nil, nil)
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
	runUrl := r.sdk.GetOrganizationUrl("runs/" + params.RunId)
	var response UpdateRunResponse
	_, err := r.sdk.Client.Post(runUrl).BodyJSON(params).ReceiveSuccess(&response)
	return &response, err
}

type UploadPlanParams struct {
	RunId string
	Plan  []byte
}

type UploadPlanResponse struct {
	Run Run `json:"run"`
}

func (r *Runs) UploadPlan(params *UploadPlanParams) (*UploadPlanResponse, error) {
	runUrl := r.sdk.GetOrganizationUrl(
		fmt.Sprintf("runs/%s/plan", r.sdk.OrganizationId, params.RunId),
	)

	var response UploadPlanResponse
	_, err := r.sdk.Client.Body(bytes.NewBuffer(params.Plan)).Post(runUrl).ReceiveSuccess(&response)
	if err != nil {
		return nil, err
	}
	return &response, nil
}

type GeneratePresignedUrlParams struct {
	RunId string
}

type GeneratePresignedUrlResponse struct {
	Url string `json:"url"`
}

func (r *Runs) PresignedUrl(params *GeneratePresignedUrlParams) (*GeneratePresignedUrlResponse, error) {
	runUrl := r.sdk.GetOrganizationUrl(
		fmt.Sprintf("runs/%s/presigned_url", params.RunId),
	)
	var response GeneratePresignedUrlResponse
	_, err := r.sdk.Client.Post(runUrl).ReceiveSuccess(&response)
	if err != nil {
		return nil, err
	}
	return &response, err
}
