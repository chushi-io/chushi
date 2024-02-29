package auth

import "github.com/gin-gonic/gin"

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
	for _, strategy := range m.strategies {
		_ = strategy.Handle(c)
	}
	return
}
