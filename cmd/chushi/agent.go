package main

import (
	"context"
	"github.com/chushi-io/chushi/internal/agent"
	"github.com/chushi-io/chushi/pkg/sdk"
	"github.com/spf13/cobra"
	"golang.org/x/oauth2/clientcredentials"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"log"
	"os"
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
	agentCmd.Flags().String("agent-id", "", "ID of the agent")
	agentCmd.Flags().String("token-url", "https://chushi.io/auth/v1/token", "Chushi Token URL")
	agentCmd.Flags().String("api-url", "https://chushi.io/api/v1/", "Chushi API URL")
	agentCmd.Flags().String("org-id", "", "ID of the organization")
	agentCmd.Flags().String("kubeconfig", "", "Location of kubeconfig file")

	rootCmd.AddCommand(agentCmd)
}

func runAgent(cmd *cobra.Command, args []string) {
	clientId := os.Getenv("CHUSHI_CLIENT_ID")
	clientSecret := os.Getenv("CHUSHI_CLIENT_SECRET")

	agentId, _ := cmd.Flags().GetString("agent-id")
	tokenUrl, _ := cmd.Flags().GetString("token-url")
	apiUrl, _ := cmd.Flags().GetString("api-url")
	orgId, _ := cmd.Flags().GetString("org-id")
	configFile, _ := cmd.Flags().GetString("kubeconfig")

	client := clientcredentials.Config{
		ClientID:     clientId,
		ClientSecret: clientSecret,
		TokenURL:     tokenUrl,
	}

	kubeClient, err := getKubeClient(configFile)
	if err != nil {
		log.Fatal(err)
	}

	cnf := &agent.Config{
		Server: &agent.ServerConfig{
			TokenUrl: tokenUrl,
			ApiUrl:   apiUrl,
		},
		Runner: &agent.RunnerConfig{
			Image:   "chushi",
			Version: "latest",
		},
		AgentId: agentId,
	}

	chushiSdk := &sdk.Sdk{
		Client:         client.Client(context.TODO()),
		ApiUrl:         cnf.Server.ApiUrl,
		TokenUrl:       cnf.Server.TokenUrl,
		OrganizationId: orgId,
	}

	ag, _ := agent.New(kubeClient, chushiSdk, cnf)

	err = ag.Run()
	if err != nil {
		log.Fatal(err)
	}
}

func getKubeClient(configFile string) (*kubernetes.Clientset, error) {
	content, err := os.ReadFile(configFile)
	if err != nil {
		return nil, err
	}
	config, err := clientcmd.RESTConfigFromKubeConfig(content)
	if err != nil {
		return nil, err
	}
	return kubernetes.NewForConfig(config)
}
