package grpc

import (
	"connectrpc.com/connect"
	"context"
	v1 "github.com/chushi-io/chushi/gen/api/v1"
)

type LogsServer struct {
}

func (ls *LogsServer) StreamLogs(ctx context.Context, req *connect.Request[v1.StreamLogsRequest]) (*connect.Response[v1.StreamLogsResponse], error) {
	return nil, nil
}

func (ls *LogsServer) UploadLogs(ctx context.Context, req *connect.Request[v1.UploadLogsRequest]) (*connect.Response[v1.UploadLogsResponse], error) {
	return nil, nil
}
