package file_manager

import (
	"context"
	"errors"
	"fmt"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
	"github.com/google/uuid"
	"io"
)

type FileManager interface {
	FetchPlan(organizationId uuid.UUID, runId uuid.UUID) ([]byte, error)
	UploadPlan(organizationId uuid.UUID, runId uuid.UUID, reader io.Reader) error
	FetchLogs(organizationId uuid.UUID, runId uuid.UUID) ([]byte, error)
	UploadLogs(organizationId uuid.UUID, runId uuid.UUID) error
	FetchState(organizationId uuid.UUID, workspaceId uuid.UUID) ([]byte, error)
	UploadState(organizationId uuid.UUID, workspaceId uuid.UUID, reader io.Reader) error
}

func New(client *s3.Client) FileManager {
	return &FileManagerImpl{S3Client: client}
}

type FileManagerImpl struct {
	S3Client *s3.Client
}

func (impl *FileManagerImpl) FetchPlan(organizationId uuid.UUID, runId uuid.UUID) ([]byte, error) {

	return []byte{}, nil
}

func (impl *FileManagerImpl) UploadPlan(organizationId uuid.UUID, runId uuid.UUID, reader io.Reader) error {
	_, err := impl.S3Client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(organizationId.String()),
		Key:    aws.String(fmt.Sprintf("runs/%s/plan", runId.String())),
		Body:   reader,
	})

	return err
}

func (impl *FileManagerImpl) FetchState(organizationId uuid.UUID, workspaceId uuid.UUID) ([]byte, error) {
	output, err := impl.S3Client.GetObject(context.TODO(), &s3.GetObjectInput{
		Bucket: aws.String(organizationId.String()),
		Key:    aws.String(workspaceId.String()),
	})
	var nsk *types.NoSuchKey
	if err != nil {
		if errors.As(err, &nsk) {
			return nil, nil
		}
		return nil, err
	}

	defer output.Body.Close()
	return io.ReadAll(output.Body)
}

func (impl *FileManagerImpl) UploadState(organizationId uuid.UUID, workspaceId uuid.UUID, reader io.Reader) error {
	_, err := impl.S3Client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(organizationId.String()),
		Key:    aws.String(workspaceId.String()),
		Body:   reader,
	})

	return err
}

func (impl *FileManagerImpl) FetchLogs(organizationId uuid.UUID, runId uuid.UUID) ([]byte, error) {
	return []byte{}, nil
}

func (impl *FileManagerImpl) UploadLogs(organizationId uuid.UUID, runId uuid.UUID) error {
	return nil
}
