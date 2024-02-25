// Code generated by protoc-gen-connect-go. DO NOT EDIT.
//
// Source: api/v1/run.proto

package apiv1connect

import (
	connect "connectrpc.com/connect"
	context "context"
	errors "errors"
	v1 "github.com/chushi-io/chushi/gen/api/v1"
	http "net/http"
	strings "strings"
)

// This is a compile-time assertion to ensure that this generated file and the connect package are
// compatible. If you get a compiler error that this constant is not defined, this code was
// generated with a version of connect newer than the one compiled into your binary. You can fix the
// problem by either regenerating this code with an older version of connect or updating the connect
// version compiled into your binary.
const _ = connect.IsAtLeastVersion1_13_0

const (
	// RunsName is the fully-qualified name of the Runs service.
	RunsName = "api.v1.Runs"
)

// These constants are the fully-qualified names of the RPCs defined in this package. They're
// exposed at runtime as Spec.Procedure and as the final two segments of the HTTP route.
//
// Note that these are different from the fully-qualified method names used by
// google.golang.org/protobuf/reflect/protoreflect. To convert from these constants to
// reflection-formatted method names, remove the leading slash and convert the remaining slash to a
// period.
const (
	// RunsListProcedure is the fully-qualified name of the Runs's List RPC.
	RunsListProcedure = "/api.v1.Runs/List"
	// RunsWatchProcedure is the fully-qualified name of the Runs's Watch RPC.
	RunsWatchProcedure = "/api.v1.Runs/Watch"
	// RunsUpdateProcedure is the fully-qualified name of the Runs's Update RPC.
	RunsUpdateProcedure = "/api.v1.Runs/Update"
)

// These variables are the protoreflect.Descriptor objects for the RPCs defined in this package.
var (
	runsServiceDescriptor      = v1.File_api_v1_run_proto.Services().ByName("Runs")
	runsListMethodDescriptor   = runsServiceDescriptor.Methods().ByName("List")
	runsWatchMethodDescriptor  = runsServiceDescriptor.Methods().ByName("Watch")
	runsUpdateMethodDescriptor = runsServiceDescriptor.Methods().ByName("Update")
)

// RunsClient is a client for the api.v1.Runs service.
type RunsClient interface {
	List(context.Context, *connect.Request[v1.ListRunsRequest]) (*connect.Response[v1.ListRunsResponse], error)
	Watch(context.Context, *connect.Request[v1.WatchRunsRequest]) (*connect.ServerStreamForClient[v1.Run], error)
	Update(context.Context, *connect.Request[v1.UpdateRunRequest]) (*connect.Response[v1.Run], error)
}

// NewRunsClient constructs a client for the api.v1.Runs service. By default, it uses the Connect
// protocol with the binary Protobuf Codec, asks for gzipped responses, and sends uncompressed
// requests. To use the gRPC or gRPC-Web protocols, supply the connect.WithGRPC() or
// connect.WithGRPCWeb() options.
//
// The URL supplied here should be the base URL for the Connect or gRPC server (for example,
// http://api.acme.com or https://acme.com/grpc).
func NewRunsClient(httpClient connect.HTTPClient, baseURL string, opts ...connect.ClientOption) RunsClient {
	baseURL = strings.TrimRight(baseURL, "/")
	return &runsClient{
		list: connect.NewClient[v1.ListRunsRequest, v1.ListRunsResponse](
			httpClient,
			baseURL+RunsListProcedure,
			connect.WithSchema(runsListMethodDescriptor),
			connect.WithClientOptions(opts...),
		),
		watch: connect.NewClient[v1.WatchRunsRequest, v1.Run](
			httpClient,
			baseURL+RunsWatchProcedure,
			connect.WithSchema(runsWatchMethodDescriptor),
			connect.WithClientOptions(opts...),
		),
		update: connect.NewClient[v1.UpdateRunRequest, v1.Run](
			httpClient,
			baseURL+RunsUpdateProcedure,
			connect.WithSchema(runsUpdateMethodDescriptor),
			connect.WithClientOptions(opts...),
		),
	}
}

// runsClient implements RunsClient.
type runsClient struct {
	list   *connect.Client[v1.ListRunsRequest, v1.ListRunsResponse]
	watch  *connect.Client[v1.WatchRunsRequest, v1.Run]
	update *connect.Client[v1.UpdateRunRequest, v1.Run]
}

// List calls api.v1.Runs.List.
func (c *runsClient) List(ctx context.Context, req *connect.Request[v1.ListRunsRequest]) (*connect.Response[v1.ListRunsResponse], error) {
	return c.list.CallUnary(ctx, req)
}

// Watch calls api.v1.Runs.Watch.
func (c *runsClient) Watch(ctx context.Context, req *connect.Request[v1.WatchRunsRequest]) (*connect.ServerStreamForClient[v1.Run], error) {
	return c.watch.CallServerStream(ctx, req)
}

// Update calls api.v1.Runs.Update.
func (c *runsClient) Update(ctx context.Context, req *connect.Request[v1.UpdateRunRequest]) (*connect.Response[v1.Run], error) {
	return c.update.CallUnary(ctx, req)
}

// RunsHandler is an implementation of the api.v1.Runs service.
type RunsHandler interface {
	List(context.Context, *connect.Request[v1.ListRunsRequest]) (*connect.Response[v1.ListRunsResponse], error)
	Watch(context.Context, *connect.Request[v1.WatchRunsRequest], *connect.ServerStream[v1.Run]) error
	Update(context.Context, *connect.Request[v1.UpdateRunRequest]) (*connect.Response[v1.Run], error)
}

// NewRunsHandler builds an HTTP handler from the service implementation. It returns the path on
// which to mount the handler and the handler itself.
//
// By default, handlers support the Connect, gRPC, and gRPC-Web protocols with the binary Protobuf
// and JSON codecs. They also support gzip compression.
func NewRunsHandler(svc RunsHandler, opts ...connect.HandlerOption) (string, http.Handler) {
	runsListHandler := connect.NewUnaryHandler(
		RunsListProcedure,
		svc.List,
		connect.WithSchema(runsListMethodDescriptor),
		connect.WithHandlerOptions(opts...),
	)
	runsWatchHandler := connect.NewServerStreamHandler(
		RunsWatchProcedure,
		svc.Watch,
		connect.WithSchema(runsWatchMethodDescriptor),
		connect.WithHandlerOptions(opts...),
	)
	runsUpdateHandler := connect.NewUnaryHandler(
		RunsUpdateProcedure,
		svc.Update,
		connect.WithSchema(runsUpdateMethodDescriptor),
		connect.WithHandlerOptions(opts...),
	)
	return "/api.v1.Runs/", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case RunsListProcedure:
			runsListHandler.ServeHTTP(w, r)
		case RunsWatchProcedure:
			runsWatchHandler.ServeHTTP(w, r)
		case RunsUpdateProcedure:
			runsUpdateHandler.ServeHTTP(w, r)
		default:
			http.NotFound(w, r)
		}
	})
}

// UnimplementedRunsHandler returns CodeUnimplemented from all methods.
type UnimplementedRunsHandler struct{}

func (UnimplementedRunsHandler) List(context.Context, *connect.Request[v1.ListRunsRequest]) (*connect.Response[v1.ListRunsResponse], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("api.v1.Runs.List is not implemented"))
}

func (UnimplementedRunsHandler) Watch(context.Context, *connect.Request[v1.WatchRunsRequest], *connect.ServerStream[v1.Run]) error {
	return connect.NewError(connect.CodeUnimplemented, errors.New("api.v1.Runs.Watch is not implemented"))
}

func (UnimplementedRunsHandler) Update(context.Context, *connect.Request[v1.UpdateRunRequest]) (*connect.Response[v1.Run], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("api.v1.Runs.Update is not implemented"))
}