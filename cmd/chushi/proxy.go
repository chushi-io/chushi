package main

import (
	"github.com/chushi-io/chushi/internal/agent/proxy"
	"github.com/spf13/cobra"
	"go.uber.org/zap"
	"golang.org/x/oauth2/clientcredentials"
	"os"
)

var proxyCmd = &cobra.Command{
	Use:   "proxy",
	Short: "Proxy service for chushi runners",
	Run:   runProxy,
}

func init() {
	proxyCmd.Flags().String("address", "localhost:5002", "Address for server to listen on")
	proxyCmd.Flags().String("grpc-url", "https://chushi.io/grpc", "GRPC URL to proxy to")
	proxyCmd.Flags().String("token-url", "https://chushi.io/auth/token", "Chushi Token URL")
	rootCmd.AddCommand(proxyCmd)
}

func runProxy(cmd *cobra.Command, args []string) {
	address, _ := cmd.Flags().GetString("address")
	grpcUrl, _ := cmd.Flags().GetString("grpc-url")
	tokenUrl, _ := cmd.Flags().GetString("token-url")

	cc := clientcredentials.Config{
		ClientID:     os.Getenv("CHUSHI_CLIENT_ID"),
		ClientSecret: os.Getenv("CHUSHI_CLIENT_SECRET"),
		TokenURL:     tokenUrl,
	}

	p := proxy.New(
		proxy.WithHttpClient(proxy.NewInsecureClient()),
		proxy.WithServerUrl(grpcUrl, cc),
		proxy.WithAddr(address),
	)

	if err := p.Run(); err != nil {
		zap.L().Fatal(err.Error())
	}
}
