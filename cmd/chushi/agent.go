package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/spf13/cobra"
	"golang.org/x/oauth2/clientcredentials"
	"io"
	v1 "k8s.io/api/core/v1"
	"k8s.io/client-go/kubernetes"
	"log"
	"net/http"
)

var agentCmd = &cobra.Command{
	Use:   "agent",
	Short: "Start a Chushi agent",
	Long: `
The agent runs on a Kubernetes cluster, and receives events from the Chushi server.

When a new run execution is requested, it will create a pod with the appropriate 
configurations and parameters, start and monitor it, and clean up once completed
`,
	// The agent listens for requested events, and on receipt,
	// starts a pod in Kubernetes to
	// - clone the project
	// - perform any other initialization
	// - run the terraform action
	// - emit the results back to Chushi server
	Run: runAgent,
}

func init() {
	agentCmd.Flags().Int("poll-interval", 2, "How often to poll the queue endpoint (seconds)")
	agentCmd.Flags().String("client-id", "", "OAuth Client ID")
	agentCmd.Flags().String("client-secret", "", "OAuth Client Secret")
	agentCmd.Flags().String("agent-id", "", "ID of the agent")
	agentCmd.Flags().String("token-url", "https://chushi.io/auth/v1/token", "Chushi Token URL")
	agentCmd.Flags().String("api-url", "https://chushi.io/api/v1/", "Chushi API URL")
	agentCmd.Flags().String("org-id", "", "ID of the organization")

	rootCmd.AddCommand(agentCmd)
}

type RunResponse struct {
	Runs []Run `json:"runs"`
}

type Run struct {
	Id          string `json:"id"`
	Status      string `json:"status"`
	WorkspaceId string `json:"workspace_id"`
}

func runAgent(cmd *cobra.Command, args []string) {
	clientId, _ := cmd.Flags().GetString("client-id")
	clientSecret, _ := cmd.Flags().GetString("client-secret")
	agentId, _ := cmd.Flags().GetString("agent-id")
	tokenUrl, _ := cmd.Flags().GetString("token-url")
	apiUrl, _ := cmd.Flags().GetString("api-url")
	orgId, _ := cmd.Flags().GetString("org-id")

	client := clientcredentials.Config{
		ClientID:     clientId,
		ClientSecret: clientSecret,
		TokenURL:     tokenUrl,
	}
	//
	//kubeClient, err := getKubeClient()
	//if err != nil {
	//	log.Fatal(err)
	//}

	sdk := &Sdk{
		Client: client.Client(context.TODO()),
		OrgId:  orgId,
		ApiUrl: apiUrl,
	}

	runs, err := sdk.GetRuns(agentId)
	if err != nil {
		log.Fatal(err)
	}
	for _, run := range runs.Runs {
		fmt.Println(run.Id)
		ws, err := sdk.GetWorkspace(run.WorkspaceId)
		if err != nil {
			log.Fatal(err)
		}
		workspace := ws.Workspace
		if workspace.Locked {
			fmt.Println("Workspace locked, skipping")
			return
		}

		// Create the kubernetes pod
		//podManifest := generatePodSpec()
	}
}

type Sdk struct {
	Client *http.Client
	ApiUrl string
	OrgId  string
}

func (s *Sdk) GetRuns(agentId string) (*RunResponse, error) {
	runsUrl := fmt.Sprintf("%sorgs/%s/agents/%s/runs", s.ApiUrl, s.OrgId, agentId)
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

type WorkspaceResponse struct {
	Workspace Workspace `json:"workspace"`
}

type Workspace struct {
	Id     string `json:"id"`
	Name   string `json:"name"`
	Locked bool   `json:"locked"`
}

func (s *Sdk) GetWorkspace(workspaceId string) (*WorkspaceResponse, error) {
	workspaceUrl := fmt.Sprintf("%sorgs/%s/workspaces/%s", s.ApiUrl, s.OrgId, workspaceId)
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

func getKubeClient() (*kubernetes.Clientset, error) {
	return &kubernetes.Clientset{}, nil
}

func generatePodSpec() *v1.PodSpec {
	podSpec := &v1.PodSpec{
		Containers: []v1.Container{
			// Actual run container
			{
				Name:    "chushi",
				Image:   "TBD",
				Command: []string{"runner"},
			},
		},
		InitContainers: []v1.Container{
			// Container to download VCS repo
		},
	}

	return podSpec
}
