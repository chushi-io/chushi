package runner

import (
	"connectrpc.com/connect"
	"context"
	"crypto/tls"
	v1 "github.com/chushi-io/chushi/gen/agent/v1"
	agentv1 "github.com/chushi-io/chushi/gen/agent/v1/agentv1connect"
	"golang.org/x/net/http2"
	"net"
	"net/http"
	"strings"
)

type logAdapter struct {
	Logs   agentv1.LogsClient
	RunId  string
	output [][]byte
}

func newLogAdapter(grpcUrl string, runId string) *logAdapter {
	logsClient := agentv1.NewLogsClient(newInsecureClient(), grpcUrl, connect.WithGRPC())
	adapter := &logAdapter{Logs: logsClient, RunId: runId}
	return adapter
}

func (adapter *logAdapter) Write(p []byte) (n int, err error) {
	adapter.output = append(adapter.output, p)
	_, err = adapter.Logs.StreamLogs(context.TODO(), connect.NewRequest(&v1.StreamLogsRequest{Content: string(p)}))
	if err != nil {
		return 0, err
	}
	return len(p), nil
}

func (adapter *logAdapter) Flush() error {
	var lines []string
	for _, log := range adapter.output {
		lines = append(lines, string(log))
	}

	_, err := adapter.Logs.UploadLogs(context.TODO(), connect.NewRequest(&v1.UploadLogsRequest{
		Content: strings.Join(lines, "\n"),
		RunId:   adapter.RunId,
	}))
	return err
}

func newInsecureClient() *http.Client {
	return &http.Client{
		Transport: &http2.Transport{
			AllowHTTP: true,
			DialTLS: func(network, addr string, _ *tls.Config) (net.Conn, error) {
				// If you're also using this client for non-h2c traffic, you may want
				// to delegate to tls.Dial if the network isn't TCP or the addr isn't
				// in an allowlist.
				return net.Dial(network, addr)
			},
			// Don't forget timeouts!
		},
	}
}
