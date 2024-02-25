package main

import (
	"context"
	"github.com/chushi-io/chushi/internal/runner"
	"github.com/spf13/cobra"
	"go.uber.org/zap"
	"os"
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

		rnr := runner.New(
			runner.WithLogger(logger),
			runner.WithGrpc(grpcUrl),
			runner.WithWorkingDirectory(workingDir),
			runner.WithVersion(tofuVersion),
			runner.WithOperation(args[0]),
		)

		if err := rnr.Run(ctx, os.Stdout); err != nil {
			logger.Fatal(err.Error())
		}
		logger.Info("run completed")
	},
}

func init() {
	runnerCmd.Flags().StringP("directory", "d", "/workspace", "The working directory")
	runnerCmd.Flags().IntP("parallellism", "p", 10, "Parallel terraform threads to run")
	runnerCmd.Flags().StringP("version", "v", "", "Terraform version to use")
	runnerCmd.Flags().String("grpc-url", "localhost:5002", "GRPC Url for streaming logs / plans")

	rootCmd.AddCommand(runnerCmd)
}
