package organization

import (
	"connectrpc.com/connect"
	"context"
	v1 "github.com/chushi-io/chushi/gen/organization/v1"
	"github.com/chushi-io/chushi/gen/organization/v1/organizationv1connect"
	"github.com/chushi-io/chushi/internal/helpers"
	"github.com/chushi-io/chushi/internal/model"
	"github.com/google/uuid"
)

type service struct {
	db *model.Queries
}

var _ organizationv1connect.OrganizationsHandler = (*service)(nil)

func (s *service) Create(ctx context.Context, req *connect.Request[v1.CreateOrganizationRequest]) (*connect.Response[v1.Organization], error) {
	org, err := s.db.CreateOrganization(ctx, model.CreateOrganizationParams{
		Type: helpers.Pointer(req.Msg.Type),
		Name: helpers.Pointer(req.Msg.Name),
	})
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(toResponse(org)), nil
}

func (s *service) Get(ctx context.Context, req *connect.Request[v1.GetOrganizationRequest]) (*connect.Response[v1.Organization], error) {
	orgId := uuid.Must(uuid.Parse(req.Msg.Id))
	org, err := s.db.GetOrganization(ctx, orgId)
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(toResponse(org)), nil
}

func (s *service) SetAgent(ctx context.Context, req *connect.Request[v1.SetOrganizationAgentRequest]) (*connect.Response[v1.Organization], error) {
	orgId := uuid.Must(uuid.Parse(req.Msg.Id))
	agentId := uuid.Must(uuid.Parse(req.Msg.DefaultAgentId))

	if err := s.db.SetOrganizationAgent(ctx, model.SetOrganizationAgentParams{
		ID:             orgId,
		DefaultAgentID: helpers.Pointer(agentId.String()),
	}); err != nil {
		return nil, err
	}
	return nil, nil
}

func toResponse(org model.Organization) *v1.Organization {

	return &v1.Organization{
		Id:                       org.ID.String(),
		CreatedAt:                org.CreatedAt.Time.String(),
		UpdatedAt:                org.UpdatedAt.Time.String(),
		DeletedAt:                org.DeletedAt.Time.String(),
		Name:                     *org.Name,
		Type:                     *org.Type,
		AllowAutoCreateWorkspace: *org.AllowAutoCreateWorkspace,
		DefaultAgentId:           *org.DefaultAgentID,
	}
}
