package registry

import (
	"bytes"
	"context"
	"errors"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
	"github.com/google/uuid"
	"io"
	"strings"
)

type Storage interface {
	Store(ctx context.Context, params *StoreParams) error
	Fetch(ctx context.Context, params *FetchParams) (io.ReadCloser, error)
}

type StorageImpl struct {
	S3Client *s3.Client
}

type StoreParams struct {
	OrganizationID uuid.UUID
	Body           io.Reader
	Namespace      string
	Name           string
	Provider       string
	Version        string
}

func generateModulePath(namespace string, name string, provider string, version string) string {
	return strings.Join([]string{
		namespace,
		name,
		provider,
		version,
	}, "/")
}

func (store StorageImpl) Store(ctx context.Context, params *StoreParams) error {
	buf := new(bytes.Buffer)
	if _, err := io.Copy(buf, params.Body); err != nil {
		return err
	}

	r := bytes.NewReader(buf.Bytes())
	_, err := store.S3Client.PutObject(ctx, &s3.PutObjectInput{
		Bucket: aws.String(params.OrganizationID.String()),
		Key: aws.String(generateModulePath(
			params.Namespace,
			params.Name,
			params.Provider,
			params.Version,
		)),
		Body: r,
	})
	return err
}

type FetchParams struct {
	OrganizationID uuid.UUID
	Namespace      string
	Name           string
	Provider       string
	Version        string
}

func (store StorageImpl) Fetch(ctx context.Context, params *FetchParams) (io.ReadCloser, error) {
	output, err := store.S3Client.GetObject(ctx, &s3.GetObjectInput{
		Bucket: aws.String(params.OrganizationID.String()),
		Key: aws.String(generateModulePath(
			params.Namespace,
			params.Name,
			params.Provider,
			params.Version,
		)),
	})
	var nsk *types.NoSuchKey
	if err != nil {
		if errors.As(err, &nsk) {
			return nil, nil
		}
		return nil, err
	}

	return output.Body, nil
}
