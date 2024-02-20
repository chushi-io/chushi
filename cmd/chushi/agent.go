package main

import (
	"github.com/chushi-io/chushi/internal/agent"
	"github.com/chushi-io/chushi/pkg/sdk"
	"github.com/google/uuid"
	"github.com/spf13/cobra"
	"go.uber.org/zap"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
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
	agentCmd.Flags().String("server-url", "", "Chushi API URL")
	agentCmd.Flags().String("grpc-url", "localhost:5001", "Chushi GRPC URL")
	agentCmd.Flags().String("org-id", "", "ID of the organization")
	agentCmd.Flags().String("kubeconfig", "", "Location of kubeconfig file")

	rootCmd.AddCommand(agentCmd)
}

func runAgent(cmd *cobra.Command, args []string) {
	agentId, _ := cmd.Flags().GetString("agent-id")
	serverUrl, _ := cmd.Flags().GetString("server-url")
	grpcUrl, _ := cmd.Flags().GetString("grpc-url")
	rawOrgId, _ := cmd.Flags().GetString("org-id")
	configFile, _ := cmd.Flags().GetString("kubeconfig")

	kubeClient, err := getKubeClient(configFile)
	if err != nil {
		log.Fatal(err)
	}

	cnf := &agent.Config{
		Runner: &agent.RunnerConfig{
			Image:   "chushi",
			Version: "latest",
		},
		AgentId: agentId,
	}

	chushiSdk := sdk.New()

	if rawOrgId != "" {
		orgId, err := uuid.Parse(rawOrgId)
		if err != nil {
			zap.L().Fatal(err.Error())
		}
		chushiSdk = chushiSdk.WithOrganizationId(orgId)
	}
	if serverUrl != "" {
		chushiSdk = chushiSdk.WithBaseUrl(serverUrl)
	}

	conn, err := grpc.Dial(
		grpcUrl,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		zap.L().Fatal(err.Error())
	}
	defer conn.Close()
	ag, _ := agent.New(kubeClient, chushiSdk, conn, cnf)

	err = ag.Run()
	if err != nil {
		zap.L().Fatal(err.Error())
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
