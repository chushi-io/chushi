package types

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Type int64

const (
	Uuid Type = iota
	String
)

type UuidOrString struct {
	Type        Type
	UuidValue   uuid.UUID
	StringValue string
}

func (uos UuidOrString) String() string {
	if uos.Type == Uuid {
		return uos.UuidValue.String()
	} else {
		return uos.StringValue
	}
}

func FromUuid(input uuid.UUID) *UuidOrString {
	return &UuidOrString{
		Type:        Uuid,
		UuidValue:   input,
		StringValue: input.String(),
	}
}

func FromString(input string) (*UuidOrString, error) {
	uid, err := uuid.Parse(input)
	if err != nil {
		return nil, err
	}
	return &UuidOrString{
		Type:        String,
		StringValue: uid.String(),
		UuidValue:   uid,
	}, nil
}

type Module interface {
	Middleware() []gin.HandlerFunc
	Routes() []Route
}

type Route interface {
	// Pattern reports the path at which this is registered.
	Pattern() string
	Method() string
	Handlers() []gin.HandlerFunc
}

type RouteImpl struct {
	pattern  string
	method   string
	handlers []gin.HandlerFunc
}

func (r RouteImpl) Pattern() string             { return r.pattern }
func (r RouteImpl) Method() string              { return r.method }
func (r RouteImpl) Handlers() []gin.HandlerFunc { return r.handlers }

func RouteRegistration(method string, pattern string, handlers []gin.HandlerFunc) Route {
	return RouteImpl{
		pattern:  pattern,
		method:   method,
		handlers: handlers,
	}
}

type GrpcRoute interface {
	Pattern() string
	Handler() gin.HandlerFunc
}

type grpcRouteImpl struct {
	pattern string
	handler gin.HandlerFunc
}

func GrpcRouteRegistration(pattern string, handler gin.HandlerFunc) GrpcRoute {
	return grpcRouteImpl{pattern, handler}
}

func (g grpcRouteImpl) Pattern() string {
	return g.pattern
}

func (g grpcRouteImpl) Handler() gin.HandlerFunc {
	return g.handler
}
