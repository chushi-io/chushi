package agent

import (
	"connectrpc.com/connect"
	"context"
	"fmt"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/clientcredentials"
	"time"
)

type AuthInterceptor struct {
	credentials clientcredentials.Config
	token       *oauth2.Token
}

func NewAuthInterceptor(
	credentials clientcredentials.Config,
) *AuthInterceptor {
	return &AuthInterceptor{credentials: credentials}
}

func (i *AuthInterceptor) WrapUnary(next connect.UnaryFunc) connect.UnaryFunc {
	// Same as previous UnaryInterceptorFunc.
	return func(
		ctx context.Context,
		req connect.AnyRequest,
	) (connect.AnyResponse, error) {
		if req.Spec().IsClient {
			if err := i.ensureToken(); err != nil {
				return nil, connect.NewError(
					connect.CodeUnauthenticated,
					err,
				)
			}
			req.Header().Set("Authorization", fmt.Sprintf("Bearer %s", i.token.AccessToken))
		}
		return next(ctx, req)
	}
}

func (i *AuthInterceptor) WrapStreamingClient(next connect.StreamingClientFunc) connect.StreamingClientFunc {
	return func(
		ctx context.Context,
		spec connect.Spec,
	) connect.StreamingClientConn {

		conn := next(ctx, spec)
		if err := i.ensureToken(); err != nil {
			return conn
		}
		conn.RequestHeader().Set("Authorization", fmt.Sprintf("Bearer %s", i.token.AccessToken))
		return conn
	}
}

func (i *AuthInterceptor) WrapStreamingHandler(next connect.StreamingHandlerFunc) connect.StreamingHandlerFunc {
	return func(
		ctx context.Context,
		conn connect.StreamingHandlerConn,
	) error {
		return next(ctx, conn)
	}
}

func (i *AuthInterceptor) ensureToken() error {
	// Generate a token if it doesn't exist
	if i.token == nil {
		token, err := i.credentials.Token(context.TODO())
		if err != nil {
			return err
		}
		i.token = token
		return nil
	}

	// Regenerate if about to expire
	expiryCheck := time.Now().Add(-time.Second * 60)
	if i.token.Expiry.After(expiryCheck) {
		token, err := i.credentials.Token(context.TODO())
		if err != nil {
			return err
		}
		i.token = token
		return nil
	}
	return nil
}
