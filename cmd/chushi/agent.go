package main

import (
	"fmt"
	"github.com/spf13/cobra"
)

var agentCmd = &cobra.Command{
	Use:   "agent",
	Short: "Start a Chushi agent",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Starting a chushi agent")
	},
}

func init() {
	rootCmd.AddCommand(agentCmd)
}
