package main

import (
	"github.com/spf13/cobra"
	"go.uber.org/zap"
	"log"
	"os"
)

var rootCmd = &cobra.Command{
	Use:   "chushi",
	Short: "OpenTofu Automation Platform",
}

func init() {
	logger := zap.Must(zap.NewProduction())
	if os.Getenv("APP_ENV") == "development" {
		logger = zap.Must(zap.NewDevelopment())
	}

	zap.ReplaceGlobals(logger)
	defer logger.Sync()
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}
