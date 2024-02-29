package webhook

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"github.com/chushi-io/chushi/internal/resource/vcs_connection"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"io"
	"net/http"
	"strings"
)

type Webhook struct {
	Repository vcs_connection.Repository
}

func New() Webhook {
	return Webhook{}
}

// We'll always return true. Ths middleware should
// only be attached to webhook endpoints
func (w Webhook) Evaluate(c *gin.Context) bool {
	return true
}

func (w Webhook) Handle(c *gin.Context) bool {
	signatureHeader := c.Request.Header.Get("X-Hub-Signature-256")
	if signatureHeader == "" {
		c.AbortWithError(http.StatusUnauthorized, errors.New("invalid signature"))
		return false
	}

	signature, found := strings.CutPrefix(signatureHeader, "sha256=")
	if !found {
		c.AbortWithError(http.StatusUnauthorized, errors.New("invalid signature"))
		return false
	}

	defer c.Request.Body.Close()

	var buf bytes.Buffer
	_, err := io.Copy(&buf, c.Request.Body)
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, errors.New("invalid body"))
		return false
	}

	webhookIdentifier := c.Param(":webhook")
	webhookId, err := uuid.Parse(webhookIdentifier)
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, errors.New("invalid webhook"))
		return false
	}

	connection, err := w.Repository.GetByWebhookId(webhookId)
	if err != nil {
		c.AbortWithError(http.StatusBadRequest, errors.New("invalid webhook"))
		return false
	}

	hash := hmac.New(sha256.New, []byte(connection.Webhook.Id.String())) // We need to load the VCS connections secret key
	if _, err := hash.Write(buf.Bytes()); err != nil {
		c.AbortWithError(http.StatusBadRequest, errors.New("bad hash"))
		return false
	}

	expectedHash := hex.EncodeToString(hash.Sum(nil))
	if expectedHash != signature {
		c.AbortWithError(http.StatusBadRequest, errors.New("invalid signature"))
		return false
	}
	c.Set("connection", connection)
	return true
}
