package grpc

import (
	"connectrpc.com/connect"
	"context"
	v1 "github.com/chushi-io/chushi/gen/api/v1"
)

type PlanServer struct {
}

func (ps *PlanServer) UploadPlan(
	ctx context.Context,
	req *connect.Request[v1.UploadPlanRequest],
) (*connect.Response[v1.UploadPlanResponse], error) {
	return nil, nil
	//org := helpers.GetOrganization(c)
	//var err error
	//var runId *types.UuidOrString
	//if runId, err = types.FromString(c.Param("run")); err != nil {
	//	c.AbortWithError(http.StatusBadRequest, err)
	//	return
	//}
	//
	//r, err := ctrl.Runs.Get(runId)
	//if err != nil {
	//	c.AbortWithError(http.StatusBadRequest, err)
	//	return
	//}
	//
	//if err = ctrl.FileManager.UploadPlan(org.ID, r.ID, c.Request.Body); err != nil {
	//	c.AbortWithError(http.StatusInternalServerError, err)
	//	return
	//}
	//c.Status(http.StatusOK)
}
