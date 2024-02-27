package grpc

import (
	"connectrpc.com/connect"
	"context"
	"errors"
	v1 "github.com/chushi-io/chushi/gen/api/v1"
	"github.com/chushi-io/chushi/internal/resource/agent"
	"github.com/chushi-io/chushi/internal/resource/run"
	"github.com/chushi-io/chushi/internal/service/file_manager"
	"github.com/chushi-io/chushi/pkg/types"
	"strings"
)

type PlanServer struct {
	Runs        run.RunRepository
	FileManager file_manager.FileManager
}

func (ps *PlanServer) UploadPlan(
	ctx context.Context,
	req *connect.Request[v1.UploadPlanRequest],
) (*connect.Response[v1.UploadPlanResponse], error) {
	check := ctx.Value("agent")
	if check == nil {
		return nil, errors.New("agent not found")
	}

	ag := ctx.Value("agent").(*agent.Agent)
	runId, err := types.FromString(req.Msg.RunId)
	if err != nil {
		return nil, err
	}

	r, err := ps.Runs.Get(runId)
	if err != nil {
		return nil, err
	}

	if err = ps.FileManager.UploadPlan(
		ag.OrganizationID,
		r.ID,
		strings.NewReader(req.Msg.Content),
	); err != nil {
		return nil, err
	}
	return connect.NewResponse(&v1.UploadPlanResponse{
		Success: true,
	}), nil
}
