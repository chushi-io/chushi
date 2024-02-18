package main

import (
	"fmt"
	"github.com/chushi-io/chushi/internal/server"
	"github.com/chushi-io/chushi/internal/server/config"
	"github.com/spf13/cobra"
	"log"
	"net"
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

		httpServer, grpcServer, err := server.New(conf)
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
		go func() {
			fmt.Println("Starting GRPC listener")
			lis, err := net.Listen("tcp", fmt.Sprintf(":%s", "5001"))
			if err != nil {
				log.Fatal(err)
			}
			if err := grpcServer.Serve(lis); err != nil {
				log.Fatal(err)
			}
		}()
		if err := httpServer.Run(); err != nil {
			log.Fatal(err)
		}
	},
}

func init() {
	serverCmd.Flags().Bool("agent", false, "Run the agent component as well")
	rootCmd.AddCommand(serverCmd)
}
