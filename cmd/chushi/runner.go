package main

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"github.com/chushi-io/chushi/internal/installer"
	"github.com/chushi-io/chushi/pkg/sdk"
	"github.com/hashicorp/go-version"
	"github.com/hashicorp/terraform-exec/tfexec"
	"github.com/spf13/cobra"
	"log"
	"os"
	"path/filepath"
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
		if len(args) == 0 {
			log.Fatal("Please provider a command to run")
		}
		ctx := context.Background()
		tofuVersion, _ := cmd.Flags().GetString("version")
		workingDir, _ := cmd.Flags().GetString("directory")

		chushiSdk := sdk.New()
		ver, err := version.NewVersion(tofuVersion)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println("Installing terraform")
		install, err := installer.Install(ver, workingDir)
		if err != nil {
			log.Fatal(err)
		}

		tf, err := tfexec.NewTerraform(workingDir, install)
		if err != nil {
			log.Fatal(err)
		}

		fmt.Println("OpenTofu installed, starting operation")
		err = tf.Init(ctx, tfexec.Upgrade(false))
		if err != nil {
			log.Fatal(err)
		}

		var hasChanges bool
		var buf bytes.Buffer
		switch args[0] {
		case "plan":
			hasChanges, err = tf.PlanJSON(ctx, &buf, tfexec.Out("tfplan"))
		case "apply":
			err = tf.ApplyJSON(ctx, &buf)
		case "destroy":
			err = tf.DestroyJSON(ctx, &buf)
		default:
			err = errors.New("command not found")
		}

		if err != nil {
			log.Fatal(err)
		}

		if args[0] == "plan" && hasChanges {
			data, err := os.ReadFile(filepath.Join(workingDir, "tfplan"))
			if err != nil {
				log.Fatal(err)
			}
			if resp, err := chushiSdk.Runs().UploadPlan(&sdk.UploadPlanParams{
				RunId: os.Getenv("CHUSHI_RUN_ID"),
				Plan:  data,
			}); err != nil {
				log.Println(resp.Run)
				log.Fatal(err)
			}
		}
	},
}

func init() {
	runnerCmd.Flags().StringP("directory", "d", "/workspace", "The working directory")
	runnerCmd.Flags().IntP("parallellism", "p", 10, "Parallel terraform threads to run")
	runnerCmd.Flags().StringP("version", "v", "", "Terraform version to use")

	rootCmd.AddCommand(runnerCmd)
}
