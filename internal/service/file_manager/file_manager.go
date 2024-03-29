package file_manager

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
	"github.com/google/uuid"
	"io"
	"time"
)

type FileManager interface {
	FetchPlan(organizationId uuid.UUID, runId uuid.UUID) ([]byte, error)
	UploadPlan(organizationId uuid.UUID, runId uuid.UUID, reader io.Reader) error
	FetchLogs(organizationId uuid.UUID, runId uuid.UUID) ([]byte, error)
	UploadLogs(organizationId uuid.UUID, runId uuid.UUID, reader io.Reader) error
	FetchState(organizationId uuid.UUID, workspaceId uuid.UUID) ([]byte, error)
	UploadState(organizationId uuid.UUID, workspaceId uuid.UUID, reader io.Reader) error
	PresignedPlanUrl(organizationId uuid.UUID, runId uuid.UUID) (string, error)
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

func (impl *FileManagerImpl) ensureBucket(organizationId uuid.UUID) error {
	_, err := impl.S3Client.HeadBucket(context.TODO(), &s3.HeadBucketInput{
		Bucket: aws.String(organizationId.String()),
	})
	// Bucket exists, return
	if err == nil {
		return nil
	}

	var notFound *types.NotFound
	if errors.As(err, &notFound) {
		_, err := impl.S3Client.CreateBucket(context.TODO(), &s3.CreateBucketInput{
			Bucket: aws.String(organizationId.String()),
		})
		return err
	}
	return err
}

func (impl *FileManagerImpl) UploadPlan(organizationId uuid.UUID, runId uuid.UUID, reader io.Reader) error {
	if err := impl.ensureBucket(organizationId); err != nil {
		return err
	}
	_, err := uploadObject(impl.S3Client, context.TODO(), organizationId.String(), planUrl(runId), reader)
	return err
}

func (impl *FileManagerImpl) FetchState(organizationId uuid.UUID, workspaceId uuid.UUID) ([]byte, error) {
	if err := impl.ensureBucket(organizationId); err != nil {
		return []byte{}, err
	}
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
	if err := impl.ensureBucket(organizationId); err != nil {
		return err
	}
	_, err := uploadObject(impl.S3Client, context.TODO(), organizationId.String(), workspaceId.String(), reader)
	return err
}

func (impl *FileManagerImpl) FetchLogs(organizationId uuid.UUID, runId uuid.UUID) ([]byte, error) {
	output, err := impl.S3Client.GetObject(context.TODO(), &s3.GetObjectInput{
		Bucket: aws.String(organizationId.String()),
		Key:    aws.String(logsUrl(runId)),
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

func (impl *FileManagerImpl) UploadLogs(organizationId uuid.UUID, runId uuid.UUID, reader io.Reader) error {
	_, err := uploadObject(impl.S3Client, context.TODO(), organizationId.String(), logsUrl(runId), reader)
	return err
}

func (impl *FileManagerImpl) PresignedPlanUrl(organizationId uuid.UUID, runId uuid.UUID) (string, error) {
	presignClient := s3.NewPresignClient(impl.S3Client)
	request, err := presignClient.PresignPutObject(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(organizationId.String()),
		Key:    aws.String(planUrl(runId)),
	}, func(opts *s3.PresignOptions) {
		opts.Expires = time.Duration(300 * int64(time.Second))
		opts.ClientOptions = []func(*s3.Options){
			func(options *s3.Options) {
				//options.BaseEndpoint = aws.String("http://host.minikube.internal:9000")
			},
		}
	})

	if err != nil {
		return "", err
	}
	return request.URL, err
}

func uploadObject(client *s3.Client, ctx context.Context, bucket string, key string, body io.Reader) (*s3.PutObjectOutput, error) {
	// TODO: This is a hack to copy the body in memory. Ideally,
	// we would pipe the original reader to the S3 client. However
	// this causes errors with the signing process
	buf := new(bytes.Buffer)
	_, err := io.Copy(buf, body)
	if err != nil {
		return nil, err
	}
	r := bytes.NewReader(buf.Bytes())
	return client.PutObject(ctx, &s3.PutObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
		Body:   r,
	})
}

func logsUrl(runId uuid.UUID) string {
	return fmt.Sprintf("runs/%s/logs", runId.String())
}

func planUrl(runId uuid.UUID) string {
	return fmt.Sprintf("runs/%s/plan", runId.String())
}
