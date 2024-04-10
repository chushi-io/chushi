package auth

import (
	"connectrpc.com/connect"
	"context"
	"errors"
	"github.com/chushi-io/chushi/internal/helpers"
	"github.com/chushi-io/chushi/internal/resource/agent"
	"github.com/chushi-io/chushi/internal/resource/oauth"
	"github.com/chushi-io/chushi/internal/server/config"
	"github.com/golang-jwt/jwt/v4"
	"go.uber.org/zap"
)

type Interceptor struct {
	logger      *zap.Logger
	conf        *config.Config
	clientStore *oauth.ClientStore
	agentStore  agent.AgentRepository
}

func NewInterceptor(
	logger *zap.Logger,
	conf *config.Config,
	clientStore *oauth.ClientStore,
	agentStore agent.AgentRepository,
) *Interceptor {
	return &Interceptor{logger, conf, clientStore, agentStore}
}

func (i *Interceptor) WrapUnary(next connect.UnaryFunc) connect.UnaryFunc {
	// Same as previous UnaryInterceptorFunc.
	return func(
		ctx context.Context,
		req connect.AnyRequest,
	) (connect.AnyResponse, error) {
		authToken, err := helpers.GetTokenFromHeader(req.Header().Get("Authorization"))
		if err != nil {
			return unauthenticated(err)
		}

		agent, err := i.validateToken(authToken)
		if err != nil {
			return unauthenticated(err)
		}

		ctx = context.WithValue(ctx, "agent", agent)
		ctx = context.WithValue(ctx, "organization_id", agent.OrganizationID)
		return next(ctx, req)
	}
}

func (i *Interceptor) WrapStreamingClient(next connect.StreamingClientFunc) connect.StreamingClientFunc {
	return func(
		ctx context.Context,
		spec connect.Spec,
	) connect.StreamingClientConn {
		i.logger.Info("Interceptor::WrapStreamingClient called")
		conn := next(ctx, spec)
		return conn
	}
}

func (i *Interceptor) WrapStreamingHandler(next connect.StreamingHandlerFunc) connect.StreamingHandlerFunc {
	return func(
		ctx context.Context,
		conn connect.StreamingHandlerConn,
	) error {
		i.logger.Info("Interceptor::WrapStreamingHandler called")
		authToken, err := helpers.GetTokenFromHeader(conn.RequestHeader().Get("Authorization"))
		if err != nil {
			return connect.NewError(connect.CodeUnauthenticated, err)
		}

		ag, err := i.validateToken(authToken)
		if err != nil {
			return connect.NewError(connect.CodeUnauthenticated, err)
		}

		ctx = context.WithValue(ctx, "agent", ag)
		ctx = context.WithValue(ctx, "organization_id", ag.OrganizationID)
		return next(ctx, conn)
	}
}

func (i *Interceptor) validateToken(authToken string) (*agent.Agent, error) {
	token, err := jwt.ParseWithClaims(authToken, &jwt.RegisteredClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return false, errors.New("unexpected signing method")
		}
		return []byte(i.conf.JwtSecretKey), nil
	})
	if err != nil {
		return nil, err
	}
	claims := token.Claims.(*jwt.RegisteredClaims)
	client, err := i.clientStore.GetByID(context.TODO(), claims.Audience[0])
	if err != nil {
		return nil, err
	}

	return i.agentStore.FindByClientId(client.GetID())
}

func unauthenticated(err error) (connect.AnyResponse, error) {
	return nil, connect.NewError(
		connect.CodeUnauthenticated,
		err,
	)
}
