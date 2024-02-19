package middleware

import "github.com/gin-gonic/gin"

type WorkspaceAccessMiddleware struct {
}

func (wam *WorkspaceAccessMiddleware) VerifyWorkspaceAccess(c *gin.Context) {
	// For now, this is a no-op. If the user has access to the organization
	// we give blanket permissions to access the workspace. Once we add roles
	// and teams, we'll want to adjust this to verify actions and scopes
}
