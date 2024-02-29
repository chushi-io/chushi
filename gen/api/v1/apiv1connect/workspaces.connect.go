// Code generated by protoc-gen-connect-go. DO NOT EDIT.
//
// Source: api/v1/workspaces.proto

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
	// WorkspacesName is the fully-qualified name of the Workspaces service.
	WorkspacesName = "api.v1.Workspaces"
)

// These constants are the fully-qualified names of the RPCs defined in this package. They're
// exposed at runtime as Spec.Procedure and as the final two segments of the HTTP route.
//
// Note that these are different from the fully-qualified method names used by
// google.golang.org/protobuf/reflect/protoreflect. To convert from these constants to
// reflection-formatted method names, remove the leading slash and convert the remaining slash to a
// period.
const (
	// WorkspacesGetWorkspaceProcedure is the fully-qualified name of the Workspaces's GetWorkspace RPC.
	WorkspacesGetWorkspaceProcedure = "/api.v1.Workspaces/GetWorkspace"
	// WorkspacesGetVcsConnectionProcedure is the fully-qualified name of the Workspaces's
	// GetVcsConnection RPC.
	WorkspacesGetVcsConnectionProcedure = "/api.v1.Workspaces/GetVcsConnection"
	// WorkspacesGetVariablesProcedure is the fully-qualified name of the Workspaces's GetVariables RPC.
	WorkspacesGetVariablesProcedure = "/api.v1.Workspaces/GetVariables"
)

// These variables are the protoreflect.Descriptor objects for the RPCs defined in this package.
var (
	workspacesServiceDescriptor                = v1.File_api_v1_workspaces_proto.Services().ByName("Workspaces")
	workspacesGetWorkspaceMethodDescriptor     = workspacesServiceDescriptor.Methods().ByName("GetWorkspace")
	workspacesGetVcsConnectionMethodDescriptor = workspacesServiceDescriptor.Methods().ByName("GetVcsConnection")
	workspacesGetVariablesMethodDescriptor     = workspacesServiceDescriptor.Methods().ByName("GetVariables")
)

// WorkspacesClient is a client for the api.v1.Workspaces service.
type WorkspacesClient interface {
	GetWorkspace(context.Context, *connect.Request[v1.GetWorkspaceRequest]) (*connect.Response[v1.GetWorkspaceResponse], error)
	GetVcsConnection(context.Context, *connect.Request[v1.GetVcsConnectionRequest]) (*connect.Response[v1.GetVcsConnectionResponse], error)
	GetVariables(context.Context, *connect.Request[v1.GetVariablesRequest]) (*connect.Response[v1.GetVariablesResponse], error)
}

// NewWorkspacesClient constructs a client for the api.v1.Workspaces service. By default, it uses
// the Connect protocol with the binary Protobuf Codec, asks for gzipped responses, and sends
// uncompressed requests. To use the gRPC or gRPC-Web protocols, supply the connect.WithGRPC() or
// connect.WithGRPCWeb() options.
//
// The URL supplied here should be the base URL for the Connect or gRPC server (for example,
// http://api.acme.com or https://acme.com/grpc).
func NewWorkspacesClient(httpClient connect.HTTPClient, baseURL string, opts ...connect.ClientOption) WorkspacesClient {
	baseURL = strings.TrimRight(baseURL, "/")
	return &workspacesClient{
		getWorkspace: connect.NewClient[v1.GetWorkspaceRequest, v1.GetWorkspaceResponse](
			httpClient,
			baseURL+WorkspacesGetWorkspaceProcedure,
			connect.WithSchema(workspacesGetWorkspaceMethodDescriptor),
			connect.WithClientOptions(opts...),
		),
		getVcsConnection: connect.NewClient[v1.GetVcsConnectionRequest, v1.GetVcsConnectionResponse](
			httpClient,
			baseURL+WorkspacesGetVcsConnectionProcedure,
			connect.WithSchema(workspacesGetVcsConnectionMethodDescriptor),
			connect.WithClientOptions(opts...),
		),
		getVariables: connect.NewClient[v1.GetVariablesRequest, v1.GetVariablesResponse](
			httpClient,
			baseURL+WorkspacesGetVariablesProcedure,
			connect.WithSchema(workspacesGetVariablesMethodDescriptor),
			connect.WithClientOptions(opts...),
		),
	}
}

// workspacesClient implements WorkspacesClient.
type workspacesClient struct {
	getWorkspace     *connect.Client[v1.GetWorkspaceRequest, v1.GetWorkspaceResponse]
	getVcsConnection *connect.Client[v1.GetVcsConnectionRequest, v1.GetVcsConnectionResponse]
	getVariables     *connect.Client[v1.GetVariablesRequest, v1.GetVariablesResponse]
}

// GetWorkspace calls api.v1.Workspaces.GetWorkspace.
func (c *workspacesClient) GetWorkspace(ctx context.Context, req *connect.Request[v1.GetWorkspaceRequest]) (*connect.Response[v1.GetWorkspaceResponse], error) {
	return c.getWorkspace.CallUnary(ctx, req)
}

// GetVcsConnection calls api.v1.Workspaces.GetVcsConnection.
func (c *workspacesClient) GetVcsConnection(ctx context.Context, req *connect.Request[v1.GetVcsConnectionRequest]) (*connect.Response[v1.GetVcsConnectionResponse], error) {
	return c.getVcsConnection.CallUnary(ctx, req)
}

// GetVariables calls api.v1.Workspaces.GetVariables.
func (c *workspacesClient) GetVariables(ctx context.Context, req *connect.Request[v1.GetVariablesRequest]) (*connect.Response[v1.GetVariablesResponse], error) {
	return c.getVariables.CallUnary(ctx, req)
}

// WorkspacesHandler is an implementation of the api.v1.Workspaces service.
type WorkspacesHandler interface {
	GetWorkspace(context.Context, *connect.Request[v1.GetWorkspaceRequest]) (*connect.Response[v1.GetWorkspaceResponse], error)
	GetVcsConnection(context.Context, *connect.Request[v1.GetVcsConnectionRequest]) (*connect.Response[v1.GetVcsConnectionResponse], error)
	GetVariables(context.Context, *connect.Request[v1.GetVariablesRequest]) (*connect.Response[v1.GetVariablesResponse], error)
}

// NewWorkspacesHandler builds an HTTP handler from the service implementation. It returns the path
// on which to mount the handler and the handler itself.
//
// By default, handlers support the Connect, gRPC, and gRPC-Web protocols with the binary Protobuf
// and JSON codecs. They also support gzip compression.
func NewWorkspacesHandler(svc WorkspacesHandler, opts ...connect.HandlerOption) (string, http.Handler) {
	workspacesGetWorkspaceHandler := connect.NewUnaryHandler(
		WorkspacesGetWorkspaceProcedure,
		svc.GetWorkspace,
		connect.WithSchema(workspacesGetWorkspaceMethodDescriptor),
		connect.WithHandlerOptions(opts...),
	)
	workspacesGetVcsConnectionHandler := connect.NewUnaryHandler(
		WorkspacesGetVcsConnectionProcedure,
		svc.GetVcsConnection,
		connect.WithSchema(workspacesGetVcsConnectionMethodDescriptor),
		connect.WithHandlerOptions(opts...),
	)
	workspacesGetVariablesHandler := connect.NewUnaryHandler(
		WorkspacesGetVariablesProcedure,
		svc.GetVariables,
		connect.WithSchema(workspacesGetVariablesMethodDescriptor),
		connect.WithHandlerOptions(opts...),
	)
	return "/api.v1.Workspaces/", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case WorkspacesGetWorkspaceProcedure:
			workspacesGetWorkspaceHandler.ServeHTTP(w, r)
		case WorkspacesGetVcsConnectionProcedure:
			workspacesGetVcsConnectionHandler.ServeHTTP(w, r)
		case WorkspacesGetVariablesProcedure:
			workspacesGetVariablesHandler.ServeHTTP(w, r)
		default:
			http.NotFound(w, r)
		}
	})
}

// UnimplementedWorkspacesHandler returns CodeUnimplemented from all methods.
type UnimplementedWorkspacesHandler struct{}

func (UnimplementedWorkspacesHandler) GetWorkspace(context.Context, *connect.Request[v1.GetWorkspaceRequest]) (*connect.Response[v1.GetWorkspaceResponse], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("api.v1.Workspaces.GetWorkspace is not implemented"))
}

func (UnimplementedWorkspacesHandler) GetVcsConnection(context.Context, *connect.Request[v1.GetVcsConnectionRequest]) (*connect.Response[v1.GetVcsConnectionResponse], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("api.v1.Workspaces.GetVcsConnection is not implemented"))
}

func (UnimplementedWorkspacesHandler) GetVariables(context.Context, *connect.Request[v1.GetVariablesRequest]) (*connect.Response[v1.GetVariablesResponse], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("api.v1.Workspaces.GetVariables is not implemented"))
}
