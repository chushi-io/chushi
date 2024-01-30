package server

import (
	"context"
	"fmt"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/robwittman/chushi/internal/models"
	"github.com/robwittman/chushi/internal/server/endpoints/organizations"
	"github.com/robwittman/chushi/internal/server/endpoints/terraform"
	"github.com/robwittman/chushi/internal/server/endpoints/vcs_connections"
	"github.com/robwittman/chushi/internal/server/endpoints/workspaces"
	"gorm.io/gorm"
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
