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

type LogsServer struct {
	Runs        run.RunRepository
	FileManager file_manager.FileManager
}

func (ls *LogsServer) StreamLogs(ctx context.Context, req *connect.Request[v1.StreamLogsRequest]) (*connect.Response[v1.StreamLogsResponse], error) {
	return connect.NewResponse(&v1.StreamLogsResponse{
		Success: true,
	}), nil
}

func (ls *LogsServer) UploadLogs(ctx context.Context, req *connect.Request[v1.UploadLogsRequest]) (*connect.Response[v1.UploadLogsResponse], error) {
	ag := ctx.Value("agent").(*agent.Agent)
	runId, err := types.FromString(req.Msg.RunId)
	if err != nil {
		return nil, err
	}
	r, err := ls.Runs.Get(runId)
	if err != nil {
		return nil, err
	}
	if *r.AgentID != ag.ID {
		return nil, errors.New("unauthorized")
	}

	err = ls.FileManager.UploadLogs(ag.OrganizationID, r.ID, strings.NewReader(req.Msg.Content))
	if err != nil {
		return nil, err
	}

	return connect.NewResponse(&v1.UploadLogsResponse{
		Success: true,
	}), nil
}
