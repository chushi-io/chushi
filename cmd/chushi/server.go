package main

import (
	"fmt"
	"github.com/chushi-io/chushi/internal/server"
	"github.com/chushi-io/chushi/internal/server/config"
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

		//runAgent, _ := cmd.Flags().GetBool("agent")
		//if runAgent {
		//	ag, err := agent.New(nil)
		//	if err != nil {
		//		log.Fatal(err)
		//	}
		//	go ag.Run()
		//}
		if err := srv.Run(); err != nil {
			log.Fatal(err)
		}
	},
}

func init() {
	serverCmd.Flags().Bool("agent", false, "Run the agent component as well")
	rootCmd.AddCommand(serverCmd)
}
