package main

import (
	"fmt"
	"github.com/hashicorp/go-version"
	"github.com/robwittman/chushi/internal/installer"
	"github.com/spf13/cobra"
	"log"
)

var downloadCmd = &cobra.Command{
	Use:   "download",
	Short: "Test downloading of OpenTofu",
	Run: func(cmd *cobra.Command, args []string) {
		v, _ := cmd.Flags().GetString("version")
		binPath, _ := cmd.Flags().GetString("bin-path")

		ver, err := version.NewVersion(v)
		if err != nil {
			log.Fatal(err)
		}
		install, err := installer.Install(ver, binPath)
		if err != nil {
			log.Fatal(err)
		}

		fmt.Println(install)

	},
}

func init() {
	downloadCmd.Flags().String("version", "", "Version to download")
	downloadCmd.Flags().String("bin-path", "", "Bin path to download to")

	rootCmd.AddCommand(downloadCmd)
}
