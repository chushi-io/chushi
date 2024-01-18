package main

import (
	"fmt"
	"github.com/spf13/cobra"
)

var runnerCmd = &cobra.Command{
	Use:   "runner",
	Short: "Execute a run for an OpenTofu workspace",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Executing run for a workspace")
	},
}

func init() {
	rootCmd.AddCommand(runnerCmd)
}
