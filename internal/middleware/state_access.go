package middleware

import (
	"encoding/base64"
	"errors"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v4"
	"github.com/google/uuid"
	"net/http"
	"strings"
)

type StateAccessClaims struct {
	Workspace    string `json:"workspace"`
	Run          string `json:"run"`
	Organization string `json:"organization"`

	jwt.RegisteredClaims
}

func VerifyStateAccess(jwtSecretKey string, repository workspaces.WorkspacesRepository) func(c *gin.Context) {
	return func(c *gin.Context) {
		header := c.Request.Header.Get("Authorization")
		if header == "" {
			c.AbortWithError(http.StatusUnauthorized, errors.New("header not found"))
			return
		}

		if strings.HasPrefix(header, "Basic ") {
			trimmedHeader, _ := strings.CutPrefix(header, "Basic ")
			// We have a token generated for a runner
			sDec, _ := base64.StdEncoding.DecodeString(trimmedHeader)
			chunks := strings.Split(string(sDec), ":")
			if len(chunks) != 2 {
				c.AbortWithError(http.StatusUnauthorized, errors.New("invalid token provided"))
				return
			}

			token, err := jwt.ParseWithClaims(chunks[1], &StateAccessClaims{}, func(token *jwt.Token) (interface{}, error) {
				if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
					return nil, errors.New("unexpected signing method")
				}
				return []byte(jwtSecretKey), nil
			})
			if err != nil {
				c.AbortWithError(http.StatusUnauthorized, err)
				return
			}

			claims, ok := token.Claims.(*StateAccessClaims)
			if !ok || !token.Valid {
				c.AbortWithError(http.StatusUnauthorized, errors.New("invalid token provided"))
				return
			}

			orgId, err := uuid.Parse(claims.Organization)
			if err != nil {
				c.AbortWithError(http.StatusUnauthorized, errors.New("invalid token provided"))
				return
			}

			ws, err := repository.FindById(orgId, c.Param("workspace"))
			if err != nil {
				c.AbortWithError(http.StatusInternalServerError, err)
				return
			}

			if claims.Workspace != ws.ID.String() {
				c.AbortWithError(http.StatusForbidden, errors.New("access denied to workspace"))
			}
			c.Set("organization_id", orgId)

		} else {
			// Verify we've already done auth here
			//trimmedHeader, _ := strings.CutPrefix(header, "Bearer ")
			//tokenId, err := uuid.Parse(trimmedHeader)
			//orgId, _ := c.Get("organization_id")
			//fmt.Println(orgId)
			orgId, _ := uuid.Parse(c.Param("organization"))
			c.Set("organization_id", orgId)
		}
	}
}
