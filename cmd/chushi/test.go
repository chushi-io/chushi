package main

import (
	"context"
	"github.com/chushi-io/chushi/internal/service/organization"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/spf13/cobra"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
	"log"
	"net/http"
	"os"
)

var testCmd = &cobra.Command{
	Use:   "test",
	Short: "Testing our GRPC services",
	Run: func(cmd *cobra.Command, args []string) {
		dbconfig, err := pgxpool.ParseConfig(os.Getenv("DATABASE_URI"))
		if err != nil {
			log.Fatal(err)
		}
		//dbconfig.AfterConnect = func(ctx context.Context, conn *pgx.Conn) error {
		//	pgxuuid.Register(conn.TypeMap())
		//	return nil
		//}
		pool, err := pgxpool.NewWithConfig(context.TODO(), dbconfig)
		if err != nil {
			log.Fatal(err)
		}

		srv := organization.New(organization.WithDatabase(pool))
		err = http.ListenAndServe(
			"localhost:8085",
			h2c.NewHandler(srv, &http2.Server{}),
		)
		if err != nil {
			log.Fatal(err)
		}
	},
}

func init() {
	rootCmd.AddCommand(testCmd)
}
