package sdk

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
	var response CreateRunnerTokenResponse
	_, err := t.sdk.Client.Post(t.sdk.TokenUrl).BodyJSON(params).ReceiveSuccess(&response)
	if err != nil {
		return nil, err
	}
	return &response, err
}
