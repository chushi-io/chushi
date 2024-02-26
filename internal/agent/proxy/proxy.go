package proxy

import (
	"connectrpc.com/connect"
	"context"
	"crypto/tls"
	"fmt"
	agentv1 "github.com/chushi-io/chushi/gen/agent/v1"
	"github.com/chushi-io/chushi/gen/agent/v1/agentv1connect"
	v1 "github.com/chushi-io/chushi/gen/api/v1"
	"github.com/chushi-io/chushi/gen/api/v1/apiv1connect"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
	"golang.org/x/oauth2/clientcredentials"
	"net"
	"net/http"
)

type Proxy struct {
	// Map of RunID with list of log messages
	logCache    map[string][]string
	serverUrl   string
	address     string
	logsClient  apiv1connect.LogsClient
	plansClient apiv1connect.PlansClient
	auth        *clientcredentials.Config
	httpClient  *http.Client
}

func New(options ...func(*Proxy)) *Proxy {
	agent := &Proxy{
		logCache: map[string][]string{},
	}
	for _, o := range options {
		o(agent)
	}
	return agent
}

func WithHttpClient(httpClient *http.Client) func(proxy *Proxy) {
	return func(proxy *Proxy) {
		proxy.httpClient = httpClient
	}
}

func WithServerUrl(serverUrl string) func(proxy *Proxy) {
	return func(proxy *Proxy) {
		proxy.logsClient = apiv1connect.NewLogsClient(newInsecureClient(), serverUrl, connect.WithGRPC())
		proxy.plansClient = apiv1connect.NewPlansClient(newInsecureClient(), serverUrl, connect.WithGRPC())
		proxy.serverUrl = serverUrl
	}
}

func WithAddr(addr string) func(proxy *Proxy) {
	return func(proxy *Proxy) {
		proxy.address = addr
	}
}

func (s *Proxy) StreamLogs(
	ctx context.Context,
	req *connect.Request[agentv1.StreamLogsRequest],
) (*connect.Response[agentv1.StreamLogsResponse], error) {
	content := req.Msg.Content
	runId := req.Msg.RunId

	if s.logCache[runId] == nil {
		s.logCache[runId] = []string{}
	}
	s.logCache[runId] = append(s.logCache[runId], content)
	res := connect.NewResponse(&agentv1.StreamLogsResponse{
		Success: true,
	})
	return res, nil
}

func (s *Proxy) UploadLogs(
	ctx context.Context,
	req *connect.Request[agentv1.UploadLogsRequest],
) (*connect.Response[agentv1.UploadLogsResponse], error) {
	// Get our buffered logs, and shop them to Chushi
	// TODO: We're buffering logs to an in memory map. We should
	// either leverage that, or ultimately remove it
	request := connect.NewRequest(&v1.UploadLogsRequest{
		Content: req.Msg.Content,
	})
	request.Header().Set("Authorization", "example")
	_, err := s.logsClient.UploadLogs(context.TODO(), request)
	if err != nil {
		return connect.NewResponse(&agentv1.UploadLogsResponse{
			Success: false,
		}), err
	}
	// Purge our cache, and inform the client we're done
	delete(s.logCache, req.Msg.RunId)
	return connect.NewResponse(&agentv1.UploadLogsResponse{
		Success: true,
	}), nil
}

func (s *Proxy) UploadPlan(
	ctx context.Context,
	req *connect.Request[agentv1.UploadPlanRequest],
) (*connect.Response[agentv1.UploadPlanResponse], error) {
	request := connect.NewRequest(&v1.UploadPlanRequest{
		Content: req.Msg.Content,
	})
	request.Header().Set("Authorization", "example")
	_, err := s.plansClient.UploadPlan(context.TODO(), request)
	if err != nil {
		return connect.NewResponse(&agentv1.UploadPlanResponse{
			Success: false,
		}), err
	}
	return connect.NewResponse(&agentv1.UploadPlanResponse{
		Success: true,
	}), nil
}

func (s *Proxy) Run() error {
	mux := http.NewServeMux()
	mux.Handle(agentv1connect.NewLogsHandler(s))
	mux.Handle(agentv1connect.NewPlansHandler(s))

	fmt.Println(s.address)
	if err := http.ListenAndServe(
		s.address,
		// Use h2c so we can serve HTTP/2 without TLS.
		h2c.NewHandler(mux, &http2.Server{}),
	); err != nil {
		panic(err)
	}
	return nil
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
