package server

import (
	"context"
	"fmt"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/go-oauth2/oauth2/v4/errors"
	"github.com/go-oauth2/oauth2/v4/generates"
	"github.com/go-oauth2/oauth2/v4/manage"
	"github.com/go-oauth2/oauth2/v4/server"
	"github.com/golang-jwt/jwt"
	"github.com/robwittman/chushi/internal/models"
	"github.com/robwittman/chushi/internal/server/endpoints/agents"
	"github.com/robwittman/chushi/internal/server/endpoints/organizations"
	"github.com/robwittman/chushi/internal/server/endpoints/runs"
	"github.com/robwittman/chushi/internal/server/endpoints/terraform"
	"github.com/robwittman/chushi/internal/server/endpoints/vcs_connections"
	"github.com/robwittman/chushi/internal/server/endpoints/workspaces"
	"gorm.io/gorm"
	"log"
	"net/http"
	"os"
)

type Factory struct {
	Database *gorm.DB
}

func (f *Factory) NewTerraformController() *terraform.Controller {
	return &terraform.Controller{}
}

func (f *Factory) NewWorkspaceController() *workspaces.Controller {
	var client *s3.Client
	if os.Getenv("USE_MINIO") != "" {
		client = getMinioClient()
	} else {
		sdkConfig, err := config.LoadDefaultConfig(context.TODO())
		if err != nil {
			fmt.Println("Couldn't load default configuration. Have you set up your AWS account?")
			fmt.Println(err)
		}
		client = s3.NewFromConfig(sdkConfig)
	}
	return &workspaces.Controller{
		Repository: models.NewWorkspacesRepository(f.Database),
		S3Client:   client,
	}
}

func (f *Factory) NewVcsConnectionsController() *vcs_connections.Controller {
	return &vcs_connections.Controller{}
}

func (f *Factory) NewOrganizationsController() *organizations.Controller {
	return &organizations.Controller{
		Repository: models.NewOrganizationRepository(f.Database),
	}
}

func (f *Factory) NewAgentsController() *agents.Controller {
	return &agents.Controller{
		Repository:     models.NewAgentRepository(f.Database, models.NewClientStore(f.Database)),
		RunsRepository: models.NewRunRepository(f.Database),
	}
}

func (f *Factory) NewRunsController() *runs.Controller {
	return &runs.Controller{
		Runs:       models.NewRunRepository(f.Database),
		Workspaces: models.NewWorkspacesRepository(f.Database),
	}
}

func (f *Factory) NewOauthServer() *server.Server {
	manager := manage.NewDefaultManager()
	manager.MustTokenStorage(models.NewTokenStore(f.Database))
	manager.MapAccessGenerate(generates.NewJWTAccessGenerate("", []byte(os.Getenv("JWT_SECRET_KEY")), jwt.SigningMethodHS512))

	// client memory store
	clientStore := models.NewClientStore(f.Database)
	manager.MapClientStorage(clientStore)
	srv := server.NewDefaultServer(manager)
	srv.SetClientInfoHandler(server.ClientFormHandler)
	srv.SetUserAuthorizationHandler(func(w http.ResponseWriter, r *http.Request) (userID string, err error) {
		userID = "testing"
		return
	})
	srv.SetInternalErrorHandler(func(err error) (re *errors.Response) {
		log.Println("Internal Error:", err.Error())
		return
	})
	srv.SetResponseErrorHandler(func(re *errors.Response) {
		log.Println("Response Error:", re.Error.Error())
	})
	return srv
}

func getMinioClient() *s3.Client {
	key := os.Getenv("AWS_ACCESS_KEY_ID")
	secret := os.Getenv("AWS_SECRET_ACCESS_KEY")

	creds := credentials.NewStaticCredentialsProvider(key, secret, "")

	customResolver := aws.EndpointResolverWithOptionsFunc(func(service, region string, options ...interface{}) (aws.Endpoint, error) {
		return aws.Endpoint{
			URL: "http://localhost:9000",
		}, nil
	})
	cfg, _ := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("us-east-1"),
		config.WithCredentialsProvider(creds),
		config.WithEndpointResolverWithOptions(customResolver))
	// Create an Amazon S3 service client
	return s3.NewFromConfig(cfg, func(o *s3.Options) {
		o.UsePathStyle = true
	})
}
