// Code generated by protoc-gen-connect-go. DO NOT EDIT.
//
// Source: api/v1/auth.proto

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
	// AuthName is the fully-qualified name of the Auth service.
	AuthName = "api.v1.Auth"
)

// These constants are the fully-qualified names of the RPCs defined in this package. They're
// exposed at runtime as Spec.Procedure and as the final two segments of the HTTP route.
//
// Note that these are different from the fully-qualified method names used by
// google.golang.org/protobuf/reflect/protoreflect. To convert from these constants to
// reflection-formatted method names, remove the leading slash and convert the remaining slash to a
// period.
const (
	// AuthGenerateRunnerTokenProcedure is the fully-qualified name of the Auth's GenerateRunnerToken
	// RPC.
	AuthGenerateRunnerTokenProcedure = "/api.v1.Auth/GenerateRunnerToken"
)

// These variables are the protoreflect.Descriptor objects for the RPCs defined in this package.
var (
	authServiceDescriptor                   = v1.File_api_v1_auth_proto.Services().ByName("Auth")
	authGenerateRunnerTokenMethodDescriptor = authServiceDescriptor.Methods().ByName("GenerateRunnerToken")
)

// AuthClient is a client for the api.v1.Auth service.
type AuthClient interface {
	GenerateRunnerToken(context.Context, *connect.Request[v1.GenerateRunnerTokenRequest]) (*connect.Response[v1.GenerateRunnerTokenResponse], error)
}

// NewAuthClient constructs a client for the api.v1.Auth service. By default, it uses the Connect
// protocol with the binary Protobuf Codec, asks for gzipped responses, and sends uncompressed
// requests. To use the gRPC or gRPC-Web protocols, supply the connect.WithGRPC() or
// connect.WithGRPCWeb() options.
//
// The URL supplied here should be the base URL for the Connect or gRPC server (for example,
// http://api.acme.com or https://acme.com/grpc).
func NewAuthClient(httpClient connect.HTTPClient, baseURL string, opts ...connect.ClientOption) AuthClient {
	baseURL = strings.TrimRight(baseURL, "/")
	return &authClient{
		generateRunnerToken: connect.NewClient[v1.GenerateRunnerTokenRequest, v1.GenerateRunnerTokenResponse](
			httpClient,
			baseURL+AuthGenerateRunnerTokenProcedure,
			connect.WithSchema(authGenerateRunnerTokenMethodDescriptor),
			connect.WithClientOptions(opts...),
		),
	}
}

// authClient implements AuthClient.
type authClient struct {
	generateRunnerToken *connect.Client[v1.GenerateRunnerTokenRequest, v1.GenerateRunnerTokenResponse]
}

// GenerateRunnerToken calls api.v1.Auth.GenerateRunnerToken.
func (c *authClient) GenerateRunnerToken(ctx context.Context, req *connect.Request[v1.GenerateRunnerTokenRequest]) (*connect.Response[v1.GenerateRunnerTokenResponse], error) {
	return c.generateRunnerToken.CallUnary(ctx, req)
}

// AuthHandler is an implementation of the api.v1.Auth service.
type AuthHandler interface {
	GenerateRunnerToken(context.Context, *connect.Request[v1.GenerateRunnerTokenRequest]) (*connect.Response[v1.GenerateRunnerTokenResponse], error)
}

// NewAuthHandler builds an HTTP handler from the service implementation. It returns the path on
// which to mount the handler and the handler itself.
//
// By default, handlers support the Connect, gRPC, and gRPC-Web protocols with the binary Protobuf
// and JSON codecs. They also support gzip compression.
func NewAuthHandler(svc AuthHandler, opts ...connect.HandlerOption) (string, http.Handler) {
	authGenerateRunnerTokenHandler := connect.NewUnaryHandler(
		AuthGenerateRunnerTokenProcedure,
		svc.GenerateRunnerToken,
		connect.WithSchema(authGenerateRunnerTokenMethodDescriptor),
		connect.WithHandlerOptions(opts...),
	)
	return "/api.v1.Auth/", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case AuthGenerateRunnerTokenProcedure:
			authGenerateRunnerTokenHandler.ServeHTTP(w, r)
		default:
			http.NotFound(w, r)
		}
	})
}

// UnimplementedAuthHandler returns CodeUnimplemented from all methods.
type UnimplementedAuthHandler struct{}

func (UnimplementedAuthHandler) GenerateRunnerToken(context.Context, *connect.Request[v1.GenerateRunnerTokenRequest]) (*connect.Response[v1.GenerateRunnerTokenResponse], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("api.v1.Auth.GenerateRunnerToken is not implemented"))
}