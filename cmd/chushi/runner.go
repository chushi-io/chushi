package main

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"github.com/hashicorp/go-version"
	"github.com/hashicorp/hc-install/product"
	"github.com/hashicorp/hc-install/releases"
	"github.com/hashicorp/terraform-exec/tfexec"
	"github.com/robwittman/chushi/pkg/sdk"
	"github.com/spf13/cobra"
	"log"
	"net/http"
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
		terraformVersion, _ := cmd.Flags().GetString("version")
		installer := &releases.ExactVersion{
			Product: product.Terraform,
			Version: version.Must(version.NewVersion(terraformVersion)),
		}
		execPath, err := installer.Install(ctx)
		if err != nil {
			log.Fatal(err)
		}

		workingDir, _ := cmd.Flags().GetString("directory")
		tf, err := tfexec.NewTerraform(workingDir, execPath)
		if err != nil {
			log.Fatal(err)
		}

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
			fmt.Println("Changes found")
			chushiSdk := &sdk.Sdk{
				Client:         &http.Client{},
				ApiUrl:         os.Getenv("CHUSHI_API_URL"),
				OrganizationId: os.Getenv("CHUSHI_ORGANIZATION"),
			}
			data, err := os.ReadFile(filepath.Join(workingDir, "tfplan"))
			if err != nil {
				log.Fatal(err)
			}
			if _, err := chushiSdk.Runs().UploadPlan(&sdk.UploadPlanParams{
				RunId: os.Getenv("CHUSHI_RUN_ID"),
				Plan:  data,
			}); err != nil {
				log.Fatal(err)
			}
		}

		fmt.Println(buf.String())
	},
}

func init() {
	runnerCmd.Flags().StringP("directory", "d", "/workspace", "The working directory")
	runnerCmd.Flags().IntP("parallellism", "p", 10, "Parallel terraform threads to run")
	runnerCmd.Flags().StringP("version", "v", "", "Terraform version to use")

	rootCmd.AddCommand(runnerCmd)
}
