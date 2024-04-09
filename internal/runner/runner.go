package runner

import (
	"connectrpc.com/connect"
	"context"
	"encoding/base64"
	"errors"
	v1 "github.com/chushi-io/chushi/gen/agent/v1"
	agentv1 "github.com/chushi-io/chushi/gen/agent/v1/agentv1connect"
	"github.com/chushi-io/chushi/internal/installer"
	"github.com/hashicorp/go-version"
	"github.com/hashicorp/terraform-exec/tfexec"
	"go.uber.org/zap"
	"io"
	"os"
	"path/filepath"
)

type RunOptions struct {
}

type Runner struct {
	logger           *zap.Logger
	grpcUrl          string
	workingDirectory string
	version          string
	operation        string
	runId            string

	writer io.Writer
}

func New(options ...func(*Runner)) *Runner {
	runner := &Runner{}
	for _, o := range options {
		o(runner)
	}
	return runner
}

func WithLogger(logger *zap.Logger) func(*Runner) {
	return func(runner *Runner) {
		runner.logger = logger
	}
}

func WithGrpc(grpcUrl string) func(*Runner) {
	return func(runner *Runner) {
		runner.grpcUrl = grpcUrl
	}
}

func WithWorkingDirectory(workingDirectory string) func(runner *Runner) {
	return func(runner *Runner) {
		runner.workingDirectory = workingDirectory
	}
}

func WithVersion(version string) func(runner *Runner) {
	return func(runner *Runner) {
		runner.version = version
	}
}

func WithOperation(operation string) func(runner *Runner) {
	return func(runner *Runner) {
		runner.operation = operation
	}
}

func WithRunId(runId string) func(runner *Runner) {
	return func(runner *Runner) {
		runner.runId = runId
	}
}

func (r *Runner) Run(ctx context.Context, out io.Writer) error {
	adapter := newLogAdapter(r.grpcUrl, r.runId)
	r.writer = io.MultiWriter(adapter, out)

	r.logger.Info("installing tofu", zap.String("version", r.version))
	ver, err := version.NewVersion(r.version)
	if err != nil {
		return err
	}
	install, err := installer.Install(ver, r.workingDirectory, r.logger)
	if err != nil {
		return err
	}

	tf, err := tfexec.NewTerraform(r.workingDirectory, install)
	if err != nil {
		return err
	}

	r.logger.Info("intializing tofu")
	err = tf.Init(ctx, tfexec.Upgrade(false))
	if err != nil {
		return err
	}

	var hasChanges bool

	switch r.operation {
	case "plan":
		hasChanges, err = tf.PlanJSON(ctx, r.writer, tfexec.Out("tfplan"))
	case "apply":
		err = tf.ApplyJSON(ctx, r.writer)
	case "destroy":
		err = tf.DestroyJSON(ctx, r.writer)
	default:
		err = errors.New("command not found")
	}

	if err != nil {
		return err
	}

	if err = adapter.Flush(); err != nil {
		r.logger.Warn(err.Error())
	}

	if r.operation == "plan" && hasChanges {

		data, err := os.ReadFile(filepath.Join(r.workingDirectory, "tfplan"))
		if err != nil {
			return err
		}

		if err := r.uploadPlan(data); err != nil {
			return err
		}
	}
	return nil
}

func (r *Runner) uploadPlan(p []byte) error {
	planClient := agentv1.NewPlansClient(
		newInsecureClient(),
		r.grpcUrl,
		connect.WithGRPC(),
	)
	_, err := planClient.UploadPlan(context.TODO(), connect.NewRequest(&v1.UploadPlanRequest{
		Content: base64.StdEncoding.EncodeToString(p),
		RunId:   r.runId,
	}))
	return err
}
