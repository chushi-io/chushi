package grpc

import (
	"connectrpc.com/connect"
	"connectrpc.com/otelconnect"
	"context"
	"github.com/chushi-io/chushi/gen/api/v1/apiv1connect"
	"github.com/chushi-io/chushi/internal/middleware/auth"
	"github.com/chushi-io/chushi/internal/server/config"
	"go.uber.org/fx"
	"go.uber.org/zap"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
	"net/http"
)

func New(
	conf *config.Config,
	logger *zap.Logger,
	auth *AuthServer,
	workspaces *WorkspaceServer,
	plans *PlanServer,
	logs *LogsServer,
	runs *RunServer,
	otelInterceptor *otelconnect.Interceptor,
	authInterceptor *auth.Interceptor,
	lc fx.Lifecycle,
) *http.ServeMux {
	interceptors := connect.WithInterceptors(authInterceptor)
	mux := http.NewServeMux()
	mux.Handle(apiv1connect.NewRunsHandler(runs, interceptors))
	mux.Handle(apiv1connect.NewAuthHandler(auth, interceptors))
	mux.Handle(apiv1connect.NewWorkspacesHandler(workspaces, interceptors))
	mux.Handle(apiv1connect.NewPlansHandler(plans, interceptors))
	mux.Handle(apiv1connect.NewLogsHandler(logs, interceptors))

	lc.Append(fx.Hook{
		OnStart: func(ctx context.Context) error {
			logger.Info("Starting GRPC server")
			go func() {
				err := http.ListenAndServe(
					"localhost:8081",
					// For gRPC clients, it's convenient to support HTTP/2 without TLS. You can
					// avoid x/net/http2 by using http.ListenAndServeTLS.
					h2c.NewHandler(mux, &http2.Server{}),
				)
				if err != nil {
					logger.Fatal(err.Error())
				}
			}()
			return nil
		},
		OnStop: func(ctx context.Context) error {
			return nil
		},
	})

	return mux
}
