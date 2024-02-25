package main

import (
	"connectrpc.com/connect"
	"context"
	"crypto/tls"
	"encoding/base64"
	"errors"
	"fmt"
	v1 "github.com/chushi-io/chushi/gen/agent/v1"
	agentv1 "github.com/chushi-io/chushi/gen/agent/v1/agentv1connect"
	"github.com/chushi-io/chushi/internal/installer"
	"github.com/hashicorp/go-version"
	"github.com/hashicorp/terraform-exec/tfexec"
	"github.com/spf13/cobra"
	"go.uber.org/zap"
	"golang.org/x/net/http2"
	"io"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"strings"
)

var runnerCmd = &cobra.Command{
	Use:   "runner",
	Short: "Execute a run for an OpenTofu workspace",
	Long: `
The Chushi runner is responsible for the actual plan / apply / destroy 
executions occuring for Chushi workspaces.'
`,
	// To keep the runner as small as possible, this should be
	// the total sum of its functionality. Its responsibility
	// should only be to install terraform (unless cached),
	// initialize the workspace, and run the appropriate command
	// The JSON output should be streamed to the Chushi server (as well
	// as cached somewhere locally in the event of issues), and then exit.
	Run: func(cmd *cobra.Command, args []string) {
		logger := zap.L()
		if len(args) == 0 {
			logger.Fatal("Please provider a command to run")
		}
		ctx := context.Background()

		grpcUrl, _ := cmd.Flags().GetString("grpc-url")
		tofuVersion, _ := cmd.Flags().GetString("version")
		workingDir, _ := cmd.Flags().GetString("directory")

		logAdapter := NewLogAdapter(grpcUrl)
		writer := io.MultiWriter(logAdapter, os.Stdout)

		logger.Info("installing tofu", zap.String("version", tofuVersion))
		ver, err := version.NewVersion(tofuVersion)
		if err != nil {
			logger.Fatal(err.Error())
		}
		install, err := installer.Install(ver, workingDir)
		if err != nil {
			logger.Fatal(err.Error())
		}

		tf, err := tfexec.NewTerraform(workingDir, install)
		if err != nil {
			logger.Fatal(err.Error())
		}

		logger.Info("intializing tofu")
		err = tf.Init(ctx, tfexec.Upgrade(false))
		if err != nil {
			logger.Fatal(err.Error())
		}

		var hasChanges bool

		switch args[0] {
		case "plan":
			hasChanges, err = tf.PlanJSON(ctx, writer, tfexec.Out("tfplan"))
		case "apply":
			err = tf.ApplyJSON(ctx, writer)
		case "destroy":
			err = tf.DestroyJSON(ctx, writer)
		default:
			err = errors.New("command not found")
		}

		if err != nil {
			fmt.Println(err)
			logger.Fatal(err.Error())
		}

		if err = logAdapter.Flush(); err != nil {
			logger.Warn(err.Error())
		}

		if args[0] == "plan" && hasChanges {

			data, err := os.ReadFile(filepath.Join(workingDir, "tfplan"))
			if err != nil {
				logger.Fatal(err.Error())
			}

			if err := uploadPlan(grpcUrl, data); err != nil {
				logger.Error(err.Error())
			}
		}
	},
}

func init() {
	runnerCmd.Flags().StringP("directory", "d", "/workspace", "The working directory")
	runnerCmd.Flags().IntP("parallellism", "p", 10, "Parallel terraform threads to run")
	runnerCmd.Flags().StringP("version", "v", "", "Terraform version to use")
	runnerCmd.Flags().String("grpc-url", "localhost:5002", "GRPC Url for streaming logs / plans")

	rootCmd.AddCommand(runnerCmd)
}

type GRPCLogAdapter struct {
	Logs   agentv1.LogsClient
	output [][]byte
}

func NewLogAdapter(grpcUrl string) *GRPCLogAdapter {
	logsClient := agentv1.NewLogsClient(newInsecureClient(), grpcUrl, connect.WithGRPC())
	adapter := &GRPCLogAdapter{Logs: logsClient}
	return adapter
}

func (adapter *GRPCLogAdapter) Write(p []byte) (n int, err error) {
	adapter.output = append(adapter.output, p)
	_, err = adapter.Logs.StreamLogs(context.TODO(), connect.NewRequest(&v1.StreamLogsRequest{Content: string(p)}))
	if err != nil {
		return 0, err
	}
	return len(p), nil
}

func (adapter *GRPCLogAdapter) Flush() error {
	var lines []string
	for _, log := range adapter.output {
		lines = append(lines, string(log))
	}

	_, err := adapter.Logs.UploadLogs(context.TODO(), connect.NewRequest(&v1.UploadLogsRequest{
		Content: strings.Join(lines, "\n"),
	}))
	return err
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

func uploadPlan(grpcUrl string, p []byte) error {
	planClient := agentv1.NewPlansClient(
		newInsecureClient(),
		grpcUrl,
		connect.WithGRPC(),
	)
	_, err := planClient.UploadPlan(context.TODO(), connect.NewRequest(&v1.UploadPlanRequest{
		Content: base64.StdEncoding.EncodeToString(p),
	}))
	return err
}
