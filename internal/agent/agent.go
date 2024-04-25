package agent

import (
	"connectrpc.com/connect"
	"context"
	"crypto/tls"
	"errors"
	apiv1 "github.com/chushi-io/chushi/gen/api/v1"
	"github.com/chushi-io/chushi/gen/api/v1/apiv1connect"
	"github.com/chushi-io/chushi/internal/agent/driver"
	"github.com/chushi-io/chushi/pkg/types"
	"go.uber.org/zap"
	"golang.org/x/net/http2"
	"golang.org/x/oauth2/clientcredentials"
	v1 "k8s.io/api/core/v1"
	"net"
	"net/http"
	"time"
)

type Agent struct {
	id                    string
	grpcUrl               string
	runnerImage           string
	runnerImagePullPolicy string
	runsClient            apiv1connect.RunsClient
	authClient            apiv1connect.AuthClient
	wsClient              apiv1connect.WorkspacesClient
	logger                *zap.Logger
	organizationId        string
	httpClient            *http.Client
	driver                driver.Driver
	token                 string
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

func WithDriver(drv driver.Driver) func(agent *Agent) {
	return func(agent *Agent) {
		agent.driver = drv
	}
}

func WithAgentId(agentId string) func(agent *Agent) {
	return func(agent *Agent) {
		agent.id = agentId
	}
}

// TODO: This should be updated to accept clientcredentials.Config to support
// rotation of expired tokens. For now, we will accept failure
func WithGrpc(grpcUrl string, creds clientcredentials.Config) func(agent *Agent) {
	interceptors := connect.WithInterceptors(
		NewAuthInterceptor(creds),
	)
	return func(agent *Agent) {
		agent.runsClient = apiv1connect.NewRunsClient(newInsecureClient(), grpcUrl, connect.WithGRPC(), interceptors)
		agent.authClient = apiv1connect.NewAuthClient(newInsecureClient(), grpcUrl, connect.WithGRPC(), interceptors)
		agent.wsClient = apiv1connect.NewWorkspacesClient(newInsecureClient(), grpcUrl, connect.WithGRPC(), interceptors)
		agent.grpcUrl = grpcUrl
	}
}

func WithRunnerImage(runnerImage string, pullPolicy string) func(agent *Agent) {
	return func(agent *Agent) {
		agent.runnerImage = runnerImage
		agent.runnerImagePullPolicy = pullPolicy
	}
}

func WithLogger(logger *zap.Logger) func(agent *Agent) {
	return func(agent *Agent) {
		agent.logger = logger
	}
}

// For now, this just queries the current list of runs,
// and exits. However, it should query the API (or stream)
// and emit runners as needed
func (a *Agent) Run() error {

	a.logger.Debug("starting runs stream")
	for {
		a.logger.Debug("checking for runs")
		stream, err := a.runsClient.Watch(context.Background(), connect.NewRequest(&apiv1.WatchRunsRequest{
			AgentId: a.id,
		}))
		if err != nil {
			return err
		}
		for {
			rcv := stream.Receive()
			if !rcv {
				break
			}
			scheduledRun := stream.Msg()
			a.logger.Debug("getting run details")
			run, err := a.runsClient.Get(context.Background(), connect.NewRequest(&apiv1.GetRunRequest{
				RunId: scheduledRun.Id,
			}))
			if err != nil {
				// Handle the error?
				a.logger.Error(err.Error())
				continue
			}
			if err := a.handle(run.Msg); err != nil {
				a.logger.Error(err.Error())
				continue
			}
			a.logger.Info("Run completed", zap.String("run.id", scheduledRun.Id))
		}
		if err := stream.Err(); err != nil {
			a.logger.Error(err.Error())
		}
		if err := stream.Close(); err != nil {
			a.logger.Error(err.Error())
		}
		time.Sleep(time.Second * 5)
	}
}

func (a *Agent) handle(run *apiv1.Run) error {

	a.logger.Debug("getting workspace data")
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

	a.logger.Debug("generating token for runner")
	token, err := a.generateToken(ws.Msg.Workspace.Id, run.Id, a.organizationId)
	if err != nil {
		return err
	}

	a.logger.Debug("updating run status")
	if _, err := a.runsClient.Update(context.TODO(), connect.NewRequest(&apiv1.UpdateRunRequest{
		Id:     run.Id,
		Status: types.RunStatusRunning,
	})); err != nil {
		return err
	}

	a.logger.Debug("getting VCS connection")
	creds, err := a.wsClient.GetVcsConnection(context.TODO(), connect.NewRequest(&apiv1.GetVcsConnectionRequest{
		WorkspaceId:  ws.Msg.Workspace.Id,
		ConnectionId: ws.Msg.Workspace.Vcs.ConnectionId,
	}))
	if err != nil {
		return err
	}

	a.logger.Debug("getting variables")
	variables, err := a.wsClient.GetVariables(context.TODO(), connect.NewRequest(&apiv1.GetVariablesRequest{
		WorkspaceId: ws.Msg.Workspace.Id,
	}))
	if err != nil {
		return err
	}

	// Build a job spec
	job := driver.NewJob(&driver.JobSpec{
		OrganizationId: a.organizationId,
		Image:          a.getRunnerImage(),
		Run:            run,
		Workspace:      ws.Msg.Workspace,
		Token:          token,
		Credentials:    creds.Msg.Token,
		Variables:      variables.Msg.Variables,
	})

	a.logger.Debug("starting job")
	_, err = a.driver.Start(job)
	if err != nil {
		return err
	}
	defer a.driver.Cleanup(job)

	a.logger.Debug("waiting for job completion")
	_, err = a.driver.Wait(job)
	if err != nil {
		return err
	}

	if job.Status.State != "succeeded" {
		if _, err := a.runsClient.Update(context.TODO(), connect.NewRequest(&apiv1.UpdateRunRequest{
			Id:     run.Id,
			Status: types.RunStatusFailed,
		})); err != nil {
			return err
		}
		return errors.New("workspace failed")
	}

	a.logger.Debug("updating run as completed")
	// Lastly, post updates back to the run
	_, err = a.runsClient.Update(context.TODO(), connect.NewRequest(&apiv1.UpdateRunRequest{
		Id:     run.Id,
		Status: types.RunStatusCompleted,
	}))
	return err
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
