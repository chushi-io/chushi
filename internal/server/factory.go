package server

import (
	"context"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/go-oauth2/oauth2/v4/errors"
	"github.com/go-oauth2/oauth2/v4/generates"
	"github.com/go-oauth2/oauth2/v4/manage"
	"github.com/go-oauth2/oauth2/v4/server"
	"github.com/golang-jwt/jwt"
	"github.com/robwittman/chushi/internal/controller"
	"github.com/robwittman/chushi/internal/resource/agent"
	"github.com/robwittman/chushi/internal/resource/oauth"
	"github.com/robwittman/chushi/internal/resource/organization"
	"github.com/robwittman/chushi/internal/resource/run"
	"github.com/robwittman/chushi/internal/resource/vcs_connection"
	"github.com/robwittman/chushi/internal/resource/workspaces"
	"github.com/robwittman/chushi/internal/service/file_manager"
	"github.com/robwittman/chushi/internal/service/run_manager"
	"gorm.io/gorm"
	"log"
	"net/http"
	"os"
)

type Factory struct {
	Database *gorm.DB
	S3Client *s3.Client
}

func NewFactory(database *gorm.DB) (*Factory, error) {
	var client *s3.Client
	if os.Getenv("USE_MINIO") != "" {
		client = getMinioClient()
	} else {
		sdkConfig, err := config.LoadDefaultConfig(context.TODO())
		if err != nil {
			return nil, err
		}
		client = s3.NewFromConfig(sdkConfig)
	}
	return &Factory{
		Database: database,
		S3Client: client,
	}, nil
}

func (f *Factory) NewWorkspaceController() *controller.WorkspacesController {

	return &controller.WorkspacesController{
		Repository: workspaces.NewWorkspacesRepository(f.Database),
		FileManager: &file_manager.FileManagerImpl{
			S3Client: f.S3Client,
		},
	}
}

func (f *Factory) NewVcsConnectionsController() *vcs_connection.Controller {
	return &vcs_connection.Controller{}
}

func (f *Factory) NewOrganizationsController() *controller.OrganizationsController {
	return &controller.OrganizationsController{
		Repository: organization.NewOrganizationRepository(f.Database),
	}
}

func (f *Factory) NewAgentsController() *controller.AgentsController {
	return &controller.AgentsController{
		Repository:     agent.NewAgentRepository(f.Database, oauth.NewClientStore(f.Database)),
		RunsRepository: run.NewRunRepository(f.Database),
	}
}

func (f *Factory) NewRunsController() *controller.RunsController {
	workspaceRepo := workspaces.NewWorkspacesRepository(f.Database)
	runsRepo := run.NewRunRepository(f.Database)
	return &controller.RunsController{
		Runs:       runsRepo,
		Workspaces: workspaceRepo,
		FileManager: &file_manager.FileManagerImpl{
			S3Client: f.S3Client,
		},
		RunManager: run_manager.New(runsRepo, workspaceRepo),
	}
}

func (f *Factory) NewOauthServer() *server.Server {
	manager := manage.NewDefaultManager()
	manager.MustTokenStorage(oauth.NewTokenStore(f.Database))
	manager.MapAccessGenerate(generates.NewJWTAccessGenerate("", []byte(os.Getenv("JWT_SECRET_KEY")), jwt.SigningMethodHS512))

	// client memory store
	clientStore := oauth.NewClientStore(f.Database)
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
