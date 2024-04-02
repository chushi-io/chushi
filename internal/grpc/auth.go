package grpc

import (
	"connectrpc.com/connect"
	"context"
	"fmt"
	v1 "github.com/chushi-io/chushi/gen/api/v1"
	"github.com/chushi-io/chushi/internal/server/config"
	"github.com/golang-jwt/jwt/v4"
)

type AuthServer struct {
	jwtSecret string
	issuerUrl string
}

func NewAuthServer(conf *config.Config) *AuthServer {
	return &AuthServer{
		jwtSecret: conf.JwtSecretKey,
		issuerUrl: conf.IssuerUrl,
	}
}

func (a *AuthServer) GenerateRunnerToken(
	ctx context.Context,
	req *connect.Request[v1.GenerateRunnerTokenRequest],
) (*connect.Response[v1.GenerateRunnerTokenResponse], error) {
	t := jwt.NewWithClaims(jwt.SigningMethodHS256,
		jwt.MapClaims{
			"workspace":    req.Msg.WorkspaceId,
			"run":          req.Msg.RunId,
			"organization": req.Msg.OrganizationId,
			"subject":      fmt.Sprintf("org/%s/workspace/%s", req.Msg.OrganizationId, req.Msg.WorkspaceId),
			"issuer":       a.issuerUrl,
		})
	s, err := t.SignedString([]byte(a.jwtSecret))
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&v1.GenerateRunnerTokenResponse{
		Token: s,
	}), nil
}
