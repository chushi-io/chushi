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
	"github.com/spf13/cobra"
	"log"
)

var runnerCmd = &cobra.Command{
	Use:   "runner",
	Short: "Execute a run for an OpenTofu workspace",
	Run: func(cmd *cobra.Command, args []string) {
		if len(args) == 0 {
			log.Fatal("Please provider a command to terraform")
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
			hasChanges, err = tf.PlanJSON(ctx, &buf)
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
		}

		fmt.Println("Run completed")
		fmt.Println(buf.String())
	},
}

func init() {
	runnerCmd.Flags().StringP("directory", "d", "/workspace", "The working directory")
	runnerCmd.Flags().IntP("parallellism", "p", 10, "Parallel terraform threads to run")
	runnerCmd.Flags().StringP("version", "v", "", "Terraform version to use")

	rootCmd.AddCommand(runnerCmd)
}
