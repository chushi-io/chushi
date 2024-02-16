package sdk

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

func (s *Sdk) GetWorkspace(workspaceId string) (*WorkspaceResponse, error) {
	workspaceUrl := s.GetOrganizationUrl("workspaces/" + workspaceId)
	var response WorkspaceResponse
	_, err := s.Client.Get(workspaceUrl).ReceiveSuccess(&response)
	if err != nil {
		return nil, err
	}
	return &response, nil
}
