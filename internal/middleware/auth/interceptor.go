package auth

import (
	"connectrpc.com/connect"
	"context"
	"errors"
	"github.com/chushi-io/chushi/internal/helpers"
	"github.com/chushi-io/chushi/internal/resource/agent"
	"github.com/chushi-io/chushi/internal/resource/oauth"
	"github.com/golang-jwt/jwt/v4"
	"os"
)

func NewAuthInterceptor(
	clientStore *oauth.ClientStore,
	agentStore agent.AgentRepository,
) connect.UnaryInterceptorFunc {
	interceptor := func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(
			ctx context.Context,
			req connect.AnyRequest,
		) (connect.AnyResponse, error) {
			authToken, err := helpers.GetTokenFromHeader(req.Header().Get("Authorization"))
			if err != nil {
				return unauthenticated(err)
			}

			token, err := jwt.ParseWithClaims(authToken, &jwt.RegisteredClaims{}, func(token *jwt.Token) (interface{}, error) {
				if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
					return nil, errors.New("unexpected signing method")
				}
				return []byte(os.Getenv("JWT_SECRET_KEY")), nil
			})
			if err != nil {
				return unauthenticated(err)
			}

			claims := token.Claims.(*jwt.RegisteredClaims)

			client, err := clientStore.GetByID(context.TODO(), claims.Audience[0])
			if err != nil {
				return unauthenticated(err)
			}

			agent, err := agentStore.FindByClientId(client.GetID())
			if err != nil {
				return unauthenticated(err)
			}

			ctx = context.WithValue(ctx, "agent", agent)
			return next(ctx, req)
		}
	}
	return interceptor
}

func unauthenticated(err error) (connect.AnyResponse, error) {
	return nil, connect.NewError(
		connect.CodeUnauthenticated,
		err,
	)
}
