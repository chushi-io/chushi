package main

import (
	"github.com/chushi-io/chushi/internal/server"
	"github.com/chushi-io/chushi/internal/server/config"
	"github.com/spf13/cobra"
	"go.uber.org/zap"
)

var serverCmd = &cobra.Command{
	Use:   "server",
	Short: "Start the Chushi server",
	Run: func(cmd *cobra.Command, args []string) {
		conf, err := config.Load()
		if err != nil {
			zap.L().Fatal(err.Error())
		}

		httpServer, err := server.New(conf)
		if err != nil {
			zap.L().Fatal(err.Error())
		}

		//go func() {
		//	zap.L().Info("Starting GRPC listener")
		//	lis, err := net.Listen("tcp", fmt.Sprintf(":%s", "5001"))
		//	if err != nil {
		//		zap.L().Fatal(err.Error())
		//	}
		//	if err := grpcServer.Serve(lis); err != nil {
		//		zap.L().Fatal(err.Error())
		//	}
		//}()

		zap.L().Info("Starting HTTP server")
		if err := httpServer.Run(); err != nil {
			zap.L().Fatal(err.Error())
		}
	},
}

func init() {
	serverCmd.Flags().Bool("agent", false, "Run the agent component as well")
	rootCmd.AddCommand(serverCmd)
}
