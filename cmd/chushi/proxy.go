package main

import (
	"context"
	"crypto/tls"
	"github.com/chushi-io/chushi/internal/agent/proxy"
	"github.com/spf13/cobra"
	"go.uber.org/zap"
	"golang.org/x/net/http2"
	"golang.org/x/oauth2/clientcredentials"
	"net"
	"net/http"
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
	proxyCmd.Flags().Bool("insecure", false, "Use insecure client")
	rootCmd.AddCommand(proxyCmd)
}

func runProxy(cmd *cobra.Command, args []string) {
	address, _ := cmd.Flags().GetString("address")
	grpcUrl, _ := cmd.Flags().GetString("grpc-url")
	tokenUrl, _ := cmd.Flags().GetString("token-url")
	insecure, _ := cmd.Flags().GetBool("insecure")

	cc := clientcredentials.Config{
		ClientID:     os.Getenv("CHUSHI_CLIENT_ID"),
		ClientSecret: os.Getenv("CHUSHI_CLIENT_SECRET"),
		TokenURL:     tokenUrl,
	}

	opts := []func(p *proxy.Proxy){
		proxy.WithServerUrl(grpcUrl),
		proxy.WithAddr(address),
	}

	if insecure {
		tokenSource := cc.TokenSource(context.TODO())
		opts = append(opts, proxy.WithHttpClient(&http.Client{
			Transport: &http2.Transport{
				AllowHTTP: true,
				DialTLS: func(network, addr string, _ *tls.Config) (net.Conn, error) {
					// If you're also using this client for non-h2c traffic, you may want
					// to delegate to tls.Di	al if the network isn't TCP or the addr isn't
					// in an allowlist.
					return net.Dial(network, addr)
				},
			},
		}))
	} else {
		opts = append(opts, proxy.WithHttpClient(cc.Client(context.TODO())))
	}

	p := proxy.New(opts...)

	if err := p.Run(); err != nil {
		zap.L().Fatal(err.Error())
	}
}
