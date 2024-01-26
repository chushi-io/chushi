package main

import (
	"fmt"
	"github.com/spf13/cobra"
)

var agentCmd = &cobra.Command{
	Use:   "agent",
	Short: "Start a Chushi agent",
	Long: `
The agent runs on a Kubernetes cluster, and receives events from the Chushi server.

When a new run execution is requested, it will create a pod with the appropriate 
configurations and parameters, start and monitor it, and clean up once completed
`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Starting a chushi agent")
	},
}

func init() {
	rootCmd.AddCommand(agentCmd)
}
