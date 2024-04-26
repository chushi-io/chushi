package organization

import (
	"github.com/chushi-io/chushi/gen/organization/v1/organizationv1connect"
	"github.com/chushi-io/chushi/internal/model"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"
	"net/http"
)

type Server struct {
	logger *zap.Logger
	db     *model.Queries
}

type OptionFunc func(*Server)

func WithLogger(logger *zap.Logger) OptionFunc {
	return func(server *Server) {
		server.logger = logger
	}
}

func WithDatabase(conn *pgxpool.Pool) OptionFunc {
	return func(server *Server) {
		server.db = model.New(conn)
	}
}

func New(options ...OptionFunc) *http.ServeMux {
	s := &Server{
		logger: zap.NewNop(),
	}

	for _, option := range options {
		option(s)
	}

	mux := http.NewServeMux()
	mux.Handle(organizationv1connect.NewOrganizationsHandler(&service{
		db: s.db,
	}))

	return mux
}
