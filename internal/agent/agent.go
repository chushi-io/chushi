package agent

import (
	"connectrpc.com/connect"
	"context"
	"crypto/tls"
	"errors"
	"fmt"
	apiv1 "github.com/chushi-io/chushi/gen/api/v1"
	"github.com/chushi-io/chushi/gen/api/v1/apiv1connect"
	"github.com/chushi-io/chushi/internal/agent/proxy"
	"go.uber.org/zap"
	"golang.org/x/net/http2"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"log"
	"net"
	"net/http"
	"os"
	"time"
)

type Agent struct {
	id                    string
	proxy                 *proxy.Proxy
	grpcUrl               string
	runnerImage           string
	runnerImagePullPolicy string
	client                *kubernetes.Clientset
	runsClient            apiv1connect.RunsClient
	authClient            apiv1connect.AuthClient
	wsClient              apiv1connect.WorkspacesClient
	logger                zap.Logger
	organizationId        string
	httpClient            *http.Client
}

func New(options ...func(*Agent)) *Agent {
	agent := &Agent{}
	for _, o := range options {
		o(agent)
	}
	return agent
}

func WithHttpClient(client *http.Client) func(agent *Agent) {
	return func(agent *Agent) {
		agent.httpClient = client
	}
}

func WithOrganizationId(organizationId string) func(agent *Agent) {
	return func(agent *Agent) {
		agent.organizationId = organizationId
	}
}

func WithKubeClient(client *kubernetes.Clientset) func(agent *Agent) {
	return func(agent *Agent) {
		agent.client = client
	}
}

func WithAgentId(agentId string) func(agent *Agent) {
	return func(agent *Agent) {
		agent.id = agentId
	}
}

func WithProxy(serverUrl string, addr string) func(agent *Agent) {
	return func(agent *Agent) {
		agent.proxy = proxy.New(
			proxy.WithServerUrl(serverUrl),
			proxy.WithAddr(addr),
			proxy.WithHttpClient(agent.httpClient),
		)
	}
}

// TODO: This should be updated to accept clientcredentials.Config to support
// rotation of expired tokens. For now, we will accept failure
func WithGrpc(grpcUrl string, token string) func(agent *Agent) {
	return func(agent *Agent) {
		agent.runsClient = apiv1connect.NewRunsClient(newInsecureClient(), grpcUrl, connect.WithGRPC())
		agent.authClient = apiv1connect.NewAuthClient(newInsecureClient(), grpcUrl, connect.WithGRPC())
		agent.grpcUrl = grpcUrl
	}
}

func WithRunnerImage(runnerImage string, pullPolicy string) func(agent *Agent) {
	return func(agent *Agent) {
		agent.runnerImage = runnerImage
		agent.runnerImagePullPolicy = pullPolicy
	}
}

func WithLogger(logger zap.Logger) func(agent *Agent) {
	return func(agent *Agent) {
		agent.logger = logger
	}
}

// For now, this just queries the current list of runs,
// and exists. However, it should query the API (or stream)
// and emit runners as needed
func (a *Agent) Run() error {
	for {
		stream, err := a.runsClient.Watch(context.Background(), connect.NewRequest(&apiv1.WatchRunsRequest{
			AgentId: a.id,
		}))
		if err != nil {
			return err
		}
		for {
			rcv := stream.Receive()
			if !rcv {
				time.Sleep(time.Second)
				continue
			}

			scheduledRun := stream.Msg()

			run, err := a.runsClient.Get(context.Background(), connect.NewRequest(&apiv1.GetRunRequest{
				RunId: scheduledRun.Id,
			}))
			if err != nil {
				// Handle the error?
				a.logger.Fatal(err.Error())
			}
			if err := a.handle(run.Msg); err != nil {
				a.logger.Fatal(err.Error())
			}
			a.logger.Info("Run completed", zap.String("run.id", scheduledRun.Id))
		}
		a.logger.Info("Sleeping before invocation")
		time.Sleep(time.Second)
	}

	return nil
}

func (a *Agent) handle(run *apiv1.Run) error {

	ws, err := a.wsClient.GetWorkspace(context.TODO(), connect.NewRequest(&apiv1.GetWorkspaceRequest{
		Id: run.WorkspaceId,
	}))
	if err != nil {
		return err
	}

	// TODO: Should we just kick off the job, and let the
	// runner itself just fail if its locked?
	if ws.Msg.Workspace.Locked {
		return errors.New("workspace is already locked")
	}

	token, err := a.generateToken(ws.Msg.Workspace.Id, run.Id, a.organizationId)
	if err != nil {
		return err
	}

	if _, err := a.runsClient.Update(context.TODO(), connect.NewRequest(&apiv1.UpdateRunRequest{
		Id:     run.Id,
		Status: "running",
	})); err != nil {
		return err
	}

	creds, err := a.wsClient.GetVcsConnection(context.TODO(), connect.NewRequest(&apiv1.GetVcsConnectionRequest{
		ConnectionId: ws.Msg.Workspace.Vcs.ConnectionId,
	}))
	if err != nil {
		return err
	}

	variables, err := a.wsClient.GetVariables(context.TODO(), connect.NewRequest(&apiv1.GetVariablesRequest{
		WorkspaceId: ws.Msg.Workspace.Id,
	}))
	if err != nil {
		return err
	}

	pod, err := a.launchPod(run, ws.Msg.Workspace, token, creds.Msg.Token, variables.Msg.Variables)
	if err != nil {
		return err
	}

	success, err := a.waitForPodCompletion(pod)
	if err != nil {
		return err
	}

	if !success {
		return errors.New("workspace failed")
	}

	// Lastly, post updates back to the run
	_, err = a.runsClient.Update(context.TODO(), connect.NewRequest(&apiv1.UpdateRunRequest{
		Id:     run.Id,
		Status: "completed",
	}))
	return err
}

func (a *Agent) waitForPodCompletion(pod *v1.Pod) (bool, error) {
loop:
	for {
		pod, err := a.client.CoreV1().
			Pods(pod.Namespace).
			Get(context.TODO(), pod.Name, metav1.GetOptions{})
		if err != nil {
			log.Fatal(err)
		}

		switch pod.Status.Phase {
		case v1.PodSucceeded:
			break loop
		case v1.PodFailed:
			return false, errors.New(pod.Status.Message)
		case v1.PodPending:
		case v1.PodRunning:
			time.Sleep(time.Second)
		}
	}

	return true, nil
}

func (a *Agent) launchPod(run *apiv1.Run, workspace *apiv1.Workspace, token string, credentials string, variables []*apiv1.Variable) (*v1.Pod, error) {
	podManifest := a.podSpecForRun(run, workspace, token, credentials, variables)
	return a.client.CoreV1().
		Pods("default").
		Create(context.TODO(), podManifest, metav1.CreateOptions{})
}

func (a *Agent) podSpecForRun(run *apiv1.Run, workspace *apiv1.Workspace, token string, response string, variables []*apiv1.Variable) *v1.Pod {
	args := []string{
		"runner",
		fmt.Sprintf("-d=/workspace/%s", workspace.Vcs.WorkingDirectory),
		"-v=1.6.6",
		run.Operation,
	}

	envVars := []v1.EnvVar{
		{
			Name:  "CHUSHI_URL",
			Value: os.Getenv("CHUSHI_URL"),
		},
		{
			Name:  "CHUSHI_ORGANIZATION",
			Value: a.organizationId,
		},
		{
			Name:  "CHUSHI_RUN_ID",
			Value: run.Id,
		},
		{
			Name:  "CHUSHI_ACCESS_TOKEN",
			Value: token,
		},
		{
			Name:  "TF_HTTP_PASSWORD",
			Value: token,
		},
		{
			Name:  "TF_HTTP_USERNAME",
			Value: "runner",
		},
	}
	for _, variable := range variables {
		if variable.Type == "environment" {
			envVars = append(envVars, v1.EnvVar{
				Name:  variable.Key,
				Value: variable.Value,
			})
		}
	}
	autoMount := false
	podSpec := v1.PodSpec{
		AutomountServiceAccountToken: &autoMount,
		Containers: []v1.Container{
			// Actual run container
			{
				Name:  "chushi",
				Image: a.getRunnerImage(),
				// TODO: This needs to be managed
				ImagePullPolicy: v1.PullNever,
				Command:         []string{"/chushi"},
				Args:            args,
				Env:             envVars,
				VolumeMounts: []v1.VolumeMount{
					{
						MountPath: "/workspace",
						Name:      "workspace",
					},
				},
			},
		},
		// Container to download VCS repo
		InitContainers: []v1.Container{
			{
				Name:  "git",
				Image: "alpine/git",
				Command: []string{
					"/bin/sh",
					"-c",
					fmt.Sprintf(`
git clone -c credential.helper='!f() { echo username=chushi; echo "password=$GITHUB_PAT"; };f' %s /workspace
`, workspace.Vcs.Source)},
				Env: []v1.EnvVar{
					{
						Name:  "GITHUB_PAT",
						Value: token,
					},
				},
				VolumeMounts: []v1.VolumeMount{
					{
						MountPath: "/workspace",
						Name:      "workspace",
					},
				},
			},
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
			Namespace:    a.organizationId,
			GenerateName: "chushi-runner-",
			Labels:       map[string]string{},
		},
		Spec: podSpec,
	}
}

func (a *Agent) getRunnerImage() string {
	if a.runnerImage != "" {
		return a.runnerImage
	}
	return "ghcr.io/chushi-io/chushi:latest"
}

func (a *Agent) getImagePullPolicy() v1.PullPolicy {
	switch a.runnerImagePullPolicy {
	case "Never":
		return v1.PullNever
	case "Always":
		return v1.PullAlways
	default:
		return v1.PullIfNotPresent
	}
}

func newInsecureClient() *http.Client {
	return &http.Client{
		Transport: &http2.Transport{
			AllowHTTP: true,
			DialTLS: func(network, addr string, _ *tls.Config) (net.Conn, error) {
				// If you're also using this client for non-h2c traffic, you may want
				// to delegate to tls.Dial if the network isn't TCP or the addr isn't
				// in an allowlist.
				return net.Dial(network, addr)
			},
			// Don't forget timeouts!
		},
	}
}

func (a *Agent) generateToken(workspaceId string, runId string, orgId string) (string, error) {
	resp, err := a.authClient.GenerateRunnerToken(context.TODO(), connect.NewRequest(&apiv1.GenerateRunnerTokenRequest{
		WorkspaceId:    workspaceId,
		RunId:          runId,
		OrganizationId: orgId,
	}))
	if err != nil {
		return "", err
	}
	return resp.Msg.Token, nil
}
