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
