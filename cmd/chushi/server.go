package main

import (
	"fmt"
	"github.com/robwittman/chushi/internal/server"
	"github.com/robwittman/chushi/internal/server/config"
	"github.com/spf13/cobra"
	"log"
)

var serverCmd = &cobra.Command{
	Use:   "server",
	Short: "Start the Chushi server",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Running chushi server")

		conf, err := config.Load()
		if err != nil {
			log.Fatal(err)
		}

		srv, err := server.New(conf)
		if err != nil {
			log.Fatal(err)
		}
		if err := srv.Run(); err != nil {
			log.Fatal(err)
		}
	},
}

func init() {
	rootCmd.AddCommand(serverCmd)
}
