package driver

import (
	"context"
	"errors"
	"fmt"
	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/api/types/image"
	"github.com/docker/docker/api/types/mount"
	"github.com/docker/docker/api/types/network"
	ocispec "github.com/opencontainers/image-spec/specs-go/v1"
	"io"
	"os"
	"time"
)

type DockerClient interface {
	ImagePull(ctx context.Context, refStr string, options image.PullOptions) (io.ReadCloser, error)
	ContainerCreate(ctx context.Context, config *container.Config, hostConfig *container.HostConfig, networkingConfig *network.NetworkingConfig, platform *ocispec.Platform, containerName string) (container.CreateResponse, error)
	ContainerStart(ctx context.Context, containerID string, options container.StartOptions) error
	ContainerInspect(ctx context.Context, containerID string) (types.ContainerJSON, error)
	ContainerLogs(ctx context.Context, container string, options container.LogsOptions) (io.ReadCloser, error)
	ContainerRemove(ctx context.Context, containerID string, options container.RemoveOptions) error
}

type Docker struct {
	Client DockerClient
}

func (d Docker) Start(job *Job) (*Job, error) {
	// Clone the git repo
	dir, err := cloneGitRepo(
		job.Spec.Run.Id,
		job.Spec.Workspace.Vcs.Source,
		job.Spec.Workspace.Vcs.Branch,
		job.Spec.Credentials,
	)
	if err != nil {
		return nil, err
	}

	// Pull the image
	_, err = d.Client.ImagePull(context.Background(), job.Spec.Image, image.PullOptions{})
	if err != nil {
		return nil, err
	}

	variables := []string{
		fmt.Sprintf("CHUSHI_URL=%s", os.Getenv("CHUSHI_URL")),
		fmt.Sprintf("CHUSHI_ORGANIZATION=%s", job.Spec.OrganizationId),
		fmt.Sprintf("CHUSHI_RUN_ID=%s", job.Spec.Run.Id),
		fmt.Sprintf("CHUSHI_ACCESS_TOKEN=%s", job.Spec.Token),
		fmt.Sprintf("TF_HTTP_PASSWORD=%s", job.Spec.Token),
		fmt.Sprintf("TF_HTTP_USERNAME=%s", "runner"),
	}
	for _, variable := range job.Spec.Variables {
		if variable.Type == "environment" {
			variables = append(variables, fmt.Sprintf("%s=%s", variable.Key, variable.Value))
		}
	}

	cont, err := d.Client.ContainerCreate(
		context.Background(),
		&container.Config{
			Image: job.Spec.Image,
			Cmd: []string{
				"runner",
				fmt.Sprintf("-d=/workspace/%s", job.Spec.Workspace.Vcs.WorkingDirectory),
				"-v=1.6.2",
				"--grpc-url=http://host.docker.internal:5002",
				job.Spec.Run.Operation,
			},
			Env: variables,
		},
		&container.HostConfig{
			Mounts: []mount.Mount{
				{
					Type:   mount.TypeBind,
					Source: dir,
					Target: "/workspace/",
				},
			},
		},
		nil,
		nil,
		job.Spec.Run.Id,
	)

	if err != nil {
		return nil, err
	}

	if err := d.Client.ContainerStart(context.Background(), cont.ID, container.StartOptions{}); err != nil {
		return nil, err
	}
	job.Status.Metadata["container_id"] = cont.ID
	return job, nil
}

func (d Docker) Wait(job *Job) (*Job, error) {
	containerId, ok := job.Status.Metadata["container_id"]
	if !ok {
		return nil, errors.New("no container ID found")
	}
	// TODO: We shouldn't sleep, instead opting
	// to check for creating / initializing states
	time.Sleep(time.Second * 10)
	for {
		data, err := d.Client.ContainerInspect(context.TODO(), containerId)
		if err != nil {
			return nil, err
		}
		if !data.State.Running {
			if data.State.ExitCode == 0 {
				return job, nil
			}
			return job, errors.New(fmt.Sprintf("Exited with code %d", data.State.ExitCode))
		}
		time.Sleep(time.Second * 1)
	}
}

func (d Docker) Cleanup(job *Job) error {
	containerId, ok := job.Status.Metadata["container_id"]
	if !ok {
		return errors.New("no container ID found")
	}
	logs, err := d.Client.ContainerLogs(context.TODO(), containerId, container.LogsOptions{
		ShowStderr: true,
		ShowStdout: true,
	})
	if err != nil {
		fmt.Println("Failed getting container logs")
	} else {
		io.Copy(os.Stdout, logs)
	}
	return d.Client.ContainerRemove(context.TODO(), containerId, container.RemoveOptions{
		RemoveVolumes: true,
		RemoveLinks:   true,
	})
}
