package token

import (
	"errors"
	"github.com/gin-gonic/gin"
	"github.com/go-oauth2/oauth2/v4/generates"
	"github.com/golang-jwt/jwt/v4"
	"github.com/google/uuid"
	"net/http"
	"strings"
)

type Token struct {
	secretKey string
}

func New(secretKey string) Token {
	return Token{secretKey: secretKey}
}

func (ta Token) Evaluate(c *gin.Context) bool {
	bearerToken := c.Request.Header.Get("Authorization")
	if bearerToken == "" {
		return false
	}

	authToken, _ := strings.CutPrefix(bearerToken, "Bearer ")
	_, err := uuid.Parse(authToken)
	return err != nil
}

func (ta Token) Handle(c *gin.Context) bool {
	bearerToken := c.Request.Header.Get("Authorization")
	if bearerToken == "" {
		return false
	}
	authToken, _ := strings.CutPrefix(bearerToken, "Bearer ")

	// Not a UUID, handle JWT
	token, err := jwt.ParseWithClaims(authToken, &generates.JWTAccessClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(ta.secretKey), nil
	})
	if err != nil {
		c.AbortWithError(http.StatusUnauthorized, err)
		return false
	}

	claims, ok := token.Claims.(*generates.JWTAccessClaims)
	if !ok || !token.Valid {
		c.AbortWithError(http.StatusUnauthorized, err)
		return false
	}

	// We'll just set the audience and subject for now
	// Downstream handlers can load the audience / subject
	// information if needed
	c.Set("claims", claims)
	c.Set("auth_type", "token")
	return true
}
