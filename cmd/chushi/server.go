package main

import (
	"github.com/chushi-io/chushi/internal/chushi"
	"github.com/spf13/cobra"
)

var serverCmd = &cobra.Command{
	Use:   "server",
	Short: "Start the Chushi server",
	Run: func(cmd *cobra.Command, args []string) {
		chushi.Server().Run()
	},
}

func init() {
	serverCmd.Flags().Bool("agent", false, "Run the agent component as well")
	rootCmd.AddCommand(serverCmd)
}
