package proxy

import (
	"connectrpc.com/connect"
	"context"
	"fmt"
	agentv1 "github.com/chushi-io/chushi/gen/agent/v1"
	"log"
)

type Proxy struct {
}

func New() *Proxy {
	return &Proxy{}
}

func (s *Proxy) StreamLogs(
	ctx context.Context,
	req *connect.Request[agentv1.StreamLogsRequest],
) (*connect.Response[agentv1.StreamLogsResponse], error) {
	fmt.Println("StreamLogs")
	log.Println("Request headers: ", req.Header())
	res := connect.NewResponse(&agentv1.StreamLogsResponse{
		Success: true,
	})
	return res, nil
}

func (s *Proxy) UploadLogs(
	ctx context.Context,
	req *connect.Request[agentv1.UploadLogsRequest],
) (*connect.Response[agentv1.UploadLogsResponse], error) {
	fmt.Println("UploadLogs")
	log.Println("Request headers: ", req.Header())
	return connect.NewResponse(&agentv1.UploadLogsResponse{
		Success: true,
	}), nil
}

func (s *Proxy) UploadPlan(
	ctx context.Context,
	req *connect.Request[agentv1.UploadPlanRequest],
) (*connect.Response[agentv1.UploadPlanResponse], error) {
	fmt.Println("UploadPlan")
	log.Println("Request headers: ", req.Header())
	return connect.NewResponse(&agentv1.UploadPlanResponse{
		Success: true,
	}), nil
}
