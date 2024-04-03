package main

import (
	"github.com/spf13/cobra"
	"log"
	"os"
	"strings"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

var migrateCmd = &cobra.Command{
	Use:   "migrate",
	Short: "Run database migrations",
	Run: func(cmd *cobra.Command, args []string) {
		m, err := migrate.New(
			"file://db/migrations",
			os.Getenv("DATABASE_URI"))
		if err != nil {
			log.Fatal(err)
		}
		if err := m.Up(); err != nil {
			// Hack to prevent errors on no change
			if !strings.Contains(err.Error(), "no change") {
				log.Fatal(err)
			} else {
				log.Println("database up to date")
			}
		}
	},
}

func init() {
	rootCmd.AddCommand(migrateCmd)
}
