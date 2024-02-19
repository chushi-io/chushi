package sdk

import (
	"fmt"
)

type Tokens struct {
	sdk *Sdk
}

type CreateRunnerTokenParams struct {
	WorkspaceId string `json:"workspace_id"`
	RunId       string `json:"run_id"`
	AgentId     string `json:"-"`
}

type CreateRunnerTokenResponse struct {
	Token string `json:"token"`
}

func (t *Tokens) CreateRunnerToken(params *CreateRunnerTokenParams) (*CreateRunnerTokenResponse, error) {
	var response CreateRunnerTokenResponse
	tokenUrl := t.sdk.GetOrganizationUrl(fmt.Sprintf("agents/%s/runner_token", params.AgentId))
	_, err := t.sdk.Client.Post(tokenUrl).BodyJSON(params).ReceiveSuccess(&response)
	if err != nil {
		return nil, err
	}
	return &response, err
}
