package middleware

import (
	"encoding/base64"
	"errors"
	"fmt"
	"github.com/chushi-io/chushi/internal/helpers"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v4"
	"net/http"
	"os"
	"strings"
)

type StateAccessClaims struct {
	Workspace string `json:"workspace"`
	Run       string `json:"run"`
	jwt.RegisteredClaims
}

func VerifyStateAccess(jwtSecretKey string, repository workspaces.WorkspacesRepository) func(c *gin.Context) {
	return func(c *gin.Context) {
		org := helpers.GetOrganization(c)

		header := c.Request.Header.Get("Authorization")
		if header == "" {
			c.AbortWithError(http.StatusUnauthorized, errors.New("header not found"))
			return
		}

		trimmedHeader, _ := strings.CutPrefix(header, "Basic ")
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
			return []byte(os.Getenv("JWT_SECRET_KEY")), nil
		})
		if err != nil {
			c.AbortWithError(http.StatusUnauthorized, err)
			return
		}

		claims, ok := token.Claims.(*StateAccessClaims)
		if !ok || !token.Valid {
			fmt.Println("Token either not valid, or not OK")
			c.AbortWithError(http.StatusUnauthorized, errors.New("invalid token provided"))
			return
		}

		ws, err := repository.FindById(org.ID, c.Param("workspace"))
		if err != nil {
			c.AbortWithError(http.StatusInternalServerError, err)
			return
		}

		if claims.Workspace != ws.ID.String() {
			c.AbortWithError(http.StatusForbidden, errors.New("access denied to workspace"))
		}
	}
}
