package main

import (
	"fmt"
	"github.com/spf13/cobra"
)

var serverCmd = &cobra.Command{
	Use:   "server",
	Short: "Start the Chushi server",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Running chushi server")
	},
}

func init() {
	rootCmd.AddCommand(serverCmd)
}
