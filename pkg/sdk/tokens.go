package sdk

import (
	"bytes"
	"encoding/json"
)

type Tokens struct {
	sdk *Sdk
}

type CreateRunnerTokenParams struct {
}

type CreateRunnerTokenResponse struct {
	AccessToken string `json:"access_token"`
	ExpiresIn   int    `json:"expires_in"`
	Scope       string `json:"scope"`
	TokenType   string `json:"token_type"`
}

func (t *Tokens) CreateRunnerToken(params *CreateRunnerTokenParams) (*CreateRunnerTokenResponse, error) {
	data, err := json.Marshal(params)
	if err != nil {
		return nil, err
	}
	res, err := t.sdk.Client.Post(t.sdk.TokenUrl, "application/json", bytes.NewReader(data))
	if err != nil {
		return nil, err
	}

	defer res.Body.Close()

	buf := new(bytes.Buffer)
	buf.ReadFrom(res.Body)
	var response CreateRunnerTokenResponse
	err = json.Unmarshal(buf.Bytes(), &response)
	return &response, err
}
