package grpc

import (
	"connectrpc.com/connect"
	"context"
	"fmt"
	v1 "github.com/chushi-io/chushi/gen/api/v1"
	"github.com/chushi-io/chushi/internal/resource/agent"
	"github.com/chushi-io/chushi/internal/resource/run"
	"github.com/chushi-io/chushi/pkg/types"
	"github.com/google/uuid"
)

type RunServer struct {
	AgentRepository agent.AgentRepository
	RunRepository   run.RunRepository
}

func (s *RunServer) Watch(
	ctx context.Context,
	req *connect.Request[v1.WatchRunsRequest],
	stream *connect.ServerStream[v1.Run],
) error {
	orgId, err := uuid.Parse("51e03fca-ef9d-4c55-93a4-ebf4dc4b1b4e")
	if err != nil {
		return err
	}
	ag, err := s.AgentRepository.FindById(orgId, req.Msg.AgentId)
	if err != nil {
		return err
	}
	for {
		runs, err := s.RunRepository.List(&run.RunListParams{
			OrganizationId: orgId,
			AgentId:        ag.ID.String(),
			Status:         "pending",
		})
		if err != nil {
			return err
		}
		for _, r := range runs {
			fmt.Println(r)
			//if err := stream.Send(connect.NewResponse(&v1.Run{
			//	Id: r.ID.String(),
			//})); err != nil {
			//	return err
			//}
		}
		// For now, we want to disable streaming. Just output the runs that exist,
		// and we'll exit
		return nil
	}
}

func (s *RunServer) List(
	ctx context.Context, req *connect.Request[v1.ListRunsRequest],
) (*connect.Response[v1.ListRunsResponse], error) {
	return nil, nil
}

func (s *RunServer) Update(
	ctx context.Context, req *connect.Request[v1.UpdateRunRequest],
) (*connect.Response[v1.Run], error) {
	runId, err := uuid.Parse(req.Msg.Id)
	if err != nil {
		return nil, err
	}
	r, err := s.RunRepository.Get(&types.UuidOrString{
		UuidValue: runId,
		Type:      types.Uuid,
	})
	if err != nil {
		return nil, err
	}

	if req.Msg.Status != "" {
		status, err := types.ToRunStatus(req.Msg.Status)
		if err != nil {
			return nil, err
		}
		r.Status = status
	}
	if req.Msg.Add != 0 {
		r.Add = int(req.Msg.Add)
	}
	if req.Msg.Change != 0 {
		r.Change = int(req.Msg.Change)
	}
	if req.Msg.Remove != 0 {
		r.Destroy = int(req.Msg.Remove)
	}
	if _, err := s.RunRepository.Update(r); err != nil {
		return nil, err
	}
	res := connect.NewResponse(&v1.Run{
		Id: r.ID.String(),
	})
	return res, nil
}
