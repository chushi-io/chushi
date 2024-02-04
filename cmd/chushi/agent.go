package main

import (
	"context"
	"fmt"
	"github.com/robwittman/chushi/internal/agent"
	"github.com/robwittman/chushi/pkg/sdk"
	"github.com/spf13/cobra"
	"golang.org/x/oauth2/clientcredentials"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"log"
	"os"
	"time"
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
	agentCmd.Flags().String("kubeconfig", "", "Location of kubeconfig file")

	rootCmd.AddCommand(agentCmd)
}

func runAgent(cmd *cobra.Command, args []string) {
	clientId, _ := cmd.Flags().GetString("client-id")
	clientSecret, _ := cmd.Flags().GetString("client-secret")
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

	sdk := &sdk.Sdk{
		Client:         client.Client(context.TODO()),
		ApiUrl:         apiUrl,
		OrganizationId: orgId,
	}

	ag, _ := agent.New(kubeClient)
	// Register stdout
	//ag.RegisterSink(os.Stdout)
	ag.RegisterSink(agent.ChangeSink{})

	runs, err := sdk.GetRuns(agentId)
	if err != nil {
		log.Fatal(err)
	}
	for _, run := range runs.Runs {
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
		podManifest := generatePodSpec(run, workspace)

		if err != nil {
			log.Fatal(err)
		}

		// Create the pod
		pod, err := kubeClient.CoreV1().
			Pods("default").
			Create(context.TODO(), podManifest, metav1.CreateOptions{})
		fmt.Println(pod.Name)

		// Ensure it starts

		// TODO: Tail the logs, piping them to stdout on the agent
		// After completion, get the full log output, and ship

		// Wait for completion
	loop:
		for {
			pod, err := kubeClient.CoreV1().
				Pods(pod.Namespace).
				Get(context.TODO(), pod.Name, metav1.GetOptions{})
			if err != nil {
				log.Fatal(err)
			}

			switch pod.Status.Phase {
			case v1.PodSucceeded:
				break loop
			case v1.PodFailed:
				log.Fatal(pod.Status.Message)
			case v1.PodPending:
			case v1.PodRunning:
				time.Sleep(time.Second)
			}
		}

		podLogOpts := v1.PodLogOptions{}
		req := kubeClient.CoreV1().Pods(pod.Namespace).GetLogs(pod.Name, &podLogOpts)
		podLogs, err := req.Stream(context.TODO())
		if err != nil {
			log.Fatal(err)
		}
		defer podLogs.Close()
		err = ag.PollLogs(podLogs)
		if err != nil {
			log.Fatal(err)
		}
		/*		str := buf.String()
				if err = sdk.ShipLogs(run.Id, str); err != nil {
					log.Fatal(err)
				}*/
		// back to Chushi server
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

func generatePodSpec(run sdk.Run, workspace sdk.Workspace) *v1.Pod {
	podSpec := v1.PodSpec{
		Containers: []v1.Container{
			// Actual run container
			{
				Name:            "chushi",
				Image:           "chushi",
				ImagePullPolicy: "Never",
				Command:         []string{"/chushi"},
				Args: []string{
					"runner",
					"-d=/workspace/testdata",
					"plan",
					"-v=1.6.6",
				},
				VolumeMounts: []v1.VolumeMount{
					{
						MountPath: "/workspace",
						Name:      "workspace",
					},
				},
			},
		},
		InitContainers: []v1.Container{
			{
				Name:  "git",
				Image: "alpine/git",
				Args: []string{
					"clone",
					"https://github.com/robwittman/chushi",
					"/workspace",
				},
				VolumeMounts: []v1.VolumeMount{
					{
						MountPath: "/workspace",
						Name:      "workspace",
					},
				},
			},
			// Container to download VCS repo
		},
		Volumes: []v1.Volume{
			{
				Name: "workspace",
				VolumeSource: v1.VolumeSource{
					EmptyDir: &v1.EmptyDirVolumeSource{},
				},
			},
		},
		RestartPolicy: v1.RestartPolicyNever,
	}

	return &v1.Pod{
		ObjectMeta: metav1.ObjectMeta{
			Namespace:    "default",
			GenerateName: "chushi-runner-",
			Labels:       map[string]string{},
		},
		Spec: podSpec,
	}
}
