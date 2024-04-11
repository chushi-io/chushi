package main

import (
	"github.com/chushi-io/chushi/internal/agent"
	"github.com/chushi-io/chushi/internal/agent/driver"
	"github.com/docker/docker/client"
	"github.com/spf13/cobra"
	"go.uber.org/zap"
	"golang.org/x/oauth2/clientcredentials"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
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
	agentCmd.Flags().String("grpc-url", "http://localhost:8080/grpc", "Chushi GRPC URL")
	agentCmd.Flags().String("org-id", "", "ID of the organization")
	agentCmd.Flags().String("kubeconfig", "", "Location of kubeconfig file")
	agentCmd.Flags().String("runner-image", "", "Image to use for runner")
	agentCmd.Flags().String("runner-image-pull-policy", "", "Pull policy for image")
	agentCmd.Flags().String("driver", "kubernetes", "Driver type to use for runs")
	rootCmd.AddCommand(agentCmd)
}

func runAgent(cmd *cobra.Command, args []string) {
	agentId, _ := cmd.Flags().GetString("agent-id")
	grpcUrl, _ := cmd.Flags().GetString("grpc-url")
	rawOrgId, _ := cmd.Flags().GetString("org-id")
	driverType, _ := cmd.Flags().GetString("driver")
	tokenUrl, _ := cmd.Flags().GetString("token-url")
	logger := zap.L()

	cc := clientcredentials.Config{
		ClientID:     os.Getenv("CHUSHI_CLIENT_ID"),
		ClientSecret: os.Getenv("CHUSHI_CLIENT_SECRET"),
		TokenURL:     tokenUrl,
	}

	opts := []func(a *agent.Agent){
		agent.WithAgentId(agentId),
		agent.WithGrpc(grpcUrl, cc),
		agent.WithOrganizationId(rawOrgId),
		agent.WithLogger(logger),
	}

	var drv driver.Driver
	switch driverType {
	case "kubernetes":
		configFile, _ := cmd.Flags().GetString("kubeconfig")
		kubeClient, err := getKubeClient(configFile)
		if err != nil {
			logger.Fatal(err.Error())
		}
		opts = append(opts, agent.WithDriver(driver.Kubernetes{
			Client: kubeClient,
		}))
	case "docker":
		cli, err := client.NewClientWithOpts(
			client.FromEnv,
			client.WithAPIVersionNegotiation(),
		)
		if err != nil {
			logger.Fatal(err.Error())
		}
		drv = driver.Docker{Client: cli}
	default:
		drv = driver.NewInlineRunner(logger, grpcUrl)
	}

	opts = append(opts, agent.WithDriver(drv))

	runnerImage, _ := cmd.Flags().GetString("runner-image")
	pullPolicy, _ := cmd.Flags().GetString("runner-image-pull-policy")
	if runnerImage != "" || pullPolicy != "" {
		opts = append(opts, agent.WithRunnerImage(runnerImage, pullPolicy))
	}

	ag := agent.New(opts...)
	if err := ag.Run(); err != nil {
		logger.Fatal(err.Error())
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
