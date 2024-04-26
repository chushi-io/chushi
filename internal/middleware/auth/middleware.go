package auth

import (
	"errors"
	"github.com/gin-gonic/gin"
	"net/http"
)

type Middleware struct {
	strategies []Strategy
}

type Strategy interface {
	Handle(ctx *gin.Context) bool
	Evaluate(ctx *gin.Context) bool
}

func WithStrategies(strategies ...Strategy) *Middleware {
	return &Middleware{strategies: strategies}
}

func (m *Middleware) Handle(c *gin.Context) {
	var strategies []Strategy
	for _, strategy := range m.strategies {
		if strategy.Evaluate(c) {
			strategies = append(strategies, strategy)
		}
	}

	for _, strategy := range strategies {
		if strategy.Handle(c) {
			return
		}
	}
	c.AbortWithError(http.StatusUnauthorized, errors.New("no valid authentication method provided"))
}

func ValidateClaims(check func(claims *ChushiClaims) bool) func(c *gin.Context) {
	return func(c *gin.Context) {
		ctxClaims, found := c.Get("claims")
		if !found {
			c.AbortWithError(http.StatusForbidden, errors.New("claims not found"))
			return
		}

		claims, ok := ctxClaims.(*ChushiClaims)
		if !ok {
			c.AbortWithError(http.StatusForbidden, errors.New("invalid claims"))
			return
		}

		if !check(claims) {
			c.AbortWithError(http.StatusForbidden, errors.New("invalid claims"))
			return
		}
		// All good...
	}
}

func ValidateOneOfClaims(checks ...func(claims *ChushiClaims) bool) func(c *gin.Context) {
	return func(c *gin.Context) {
		ctxClaims, found := c.Get("claims")
		if !found {
			c.AbortWithError(http.StatusForbidden, errors.New("claims not found"))
			return
		}

		claims, ok := ctxClaims.(*ChushiClaims)
		if !ok {
			c.AbortWithError(http.StatusForbidden, errors.New("invalid claims"))
			return
		}

		for _, check := range checks {
			if check(claims) {
				return
			}
		}
		c.AbortWithError(http.StatusForbidden, errors.New("invalid claims"))
		return
	}
}

func ValidateAllClaims(checks ...func(claims *ChushiClaims) bool) func(c *gin.Context) {
	return func(c *gin.Context) {
		ctxClaims, found := c.Get("claims")
		if !found {
			c.AbortWithError(http.StatusForbidden, errors.New("claims not found"))
			return
		}

		claims, ok := ctxClaims.(*ChushiClaims)
		if !ok {
			c.AbortWithError(http.StatusForbidden, errors.New("invalid claims"))
			return
		}

		for _, check := range checks {
			if !check(claims) {
				c.AbortWithError(http.StatusForbidden, errors.New("invalid claims"))
				return
			}
		}

		return
	}
}
