package grpc

import (
	"context"
	"github.com/chushi-io/chushi/internal/resource/agent"
	"github.com/chushi-io/chushi/internal/resource/run"
	"github.com/chushi-io/chushi/pkg/types"
	pb "github.com/chushi-io/chushi/proto/api/v1"
	"github.com/google/uuid"
)

type RunServer struct {
	pb.UnimplementedRunsServer
	AgentRepository agent.AgentRepository
	RunRepository   run.RunRepository
}

func (s *RunServer) Watch(request *pb.WatchRunsRequest, stream pb.Runs_WatchServer) error {
	orgId, err := uuid.Parse("51e03fca-ef9d-4c55-93a4-ebf4dc4b1b4e")
	if err != nil {
		return err
	}
	ag, err := s.AgentRepository.FindById(orgId, request.AgentId)
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
			if err := stream.Send(&pb.Run{Id: r.ID.String()}); err != nil {
				return err
			}
		}
		// For now, we want to disable streaming. Just output the runs that exist,
		// and we'll exit
		return nil
	}
}

func (s *RunServer) List(ctx context.Context, req *pb.ListRunsRequest) (*pb.ListRunsResponse, error) {
	return nil, nil
}

func (s *RunServer) Update(ctx context.Context, req *pb.UpdateRunRequest) (*pb.Run, error) {
	runId, err := uuid.Parse(req.Id)
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

	if req.Status != "" {
		status, err := types.ToRunStatus(req.Status)
		if err != nil {
			return nil, err
		}
		r.Status = status
	}
	if req.Add != 0 {
		r.Add = int(req.Add)
	}
	if req.Change != 0 {
		r.Change = int(req.Change)
	}
	if req.Remove != 0 {
		r.Destroy = int(req.Remove)
	}
	if _, err := s.RunRepository.Update(r); err != nil {
		return nil, err
	}
	return &pb.Run{Id: r.ID.String()}, nil
}
