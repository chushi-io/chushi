package driver

import (
	"context"
	"errors"
	"fmt"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"os"
	"time"
)

type Kubernetes struct {
	Client *kubernetes.Clientset
}

func (k Kubernetes) Start(job *Job) (*Job, error) {
	podSpec := podSpecForRun(job)
	pod, err := k.Client.
		CoreV1().
		Pods("default").
		Create(context.TODO(), podSpec, metav1.CreateOptions{})
	if err != nil {
		return nil, err
	}
	job.Status.Metadata = map[string]string{
		"namespace": pod.Namespace,
		"name":      pod.Name,
	}
	return job, nil
}

func (k Kubernetes) Wait(job *Job) (*Job, error) {
	namespace, err := job.GetMetadata("namespace")
	if err != nil {
		return nil, err
	}
	name, err := job.GetMetadata("name")
	if err != nil {
		return nil, err
	}
loop:
	for {
		pod, err := k.Client.CoreV1().
			Pods(namespace).
			Get(context.TODO(), name, metav1.GetOptions{})
		if err != nil {
			return nil, err
		}

		switch pod.Status.Phase {
		case v1.PodSucceeded:
			job.Status.State = "succeeded"
			break loop
		case v1.PodFailed:
			job.Status.State = "failed"
			return nil, errors.New(pod.Status.Message)
		case v1.PodPending:
		case v1.PodRunning:
		default:
			job.Status.State = "running"
			time.Sleep(time.Second)
		}
	}

	return job, nil
}

func (k Kubernetes) Cleanup(job *Job) error {
	namespace, err := job.GetMetadata("namespace")
	if err != nil {
		return err
	}
	name, err := job.GetMetadata("name")
	if err != nil {
		return err
	}
	return k.Client.CoreV1().Pods(namespace).Delete(context.TODO(), name, metav1.DeleteOptions{})
}

func podSpecForRun(job *Job) *v1.Pod {
	args := []string{
		"runner",
		fmt.Sprintf("-d=/workspace/%s", job.Spec.Workspace.Vcs.WorkingDirectory),
		"-v=1.6.6",
		job.Spec.Run.Operation,
	}

	envVars := []v1.EnvVar{
		{
			Name:  "CHUSHI_URL",
			Value: os.Getenv("CHUSHI_URL"),
		},
		{
			Name:  "CHUSHI_ORGANIZATION",
			Value: job.Spec.OrganizationId,
		},
		{
			Name:  "CHUSHI_RUN_ID",
			Value: job.Spec.Run.Id,
		},
		{
			Name:  "CHUSHI_ACCESS_TOKEN",
			Value: job.Spec.Token,
		},
		{
			Name:  "TF_HTTP_PASSWORD",
			Value: job.Spec.Token,
		},
		{
			Name:  "TF_HTTP_USERNAME",
			Value: "runner",
		},
	}
	for _, variable := range job.Spec.Variables {
		if variable.Type == "environment" {
			envVars = append(envVars, v1.EnvVar{
				Name:  variable.Key,
				Value: variable.Value,
			})
		}
	}
	autoMount := false
	podSpec := v1.PodSpec{
		AutomountServiceAccountToken: &autoMount,
		Containers: []v1.Container{
			// Actual run container
			{
				Name:  "chushi",
				Image: job.Spec.Image,
				// TODO: This needs to be managed
				ImagePullPolicy: v1.PullNever,
				Command:         []string{"/chushi"},
				Args:            args,
				Env:             envVars,
				VolumeMounts: []v1.VolumeMount{
					{
						MountPath: "/workspace",
						Name:      "workspace",
					},
				},
			},
		},
		// Container to download VCS repo
		InitContainers: []v1.Container{
			{
				Name:  "git",
				Image: "alpine/git",
				Command: []string{
					"/bin/sh",
					"-c",
					fmt.Sprintf(`
git clone -c credential.helper='!f() { echo username=chushi; echo "password=$GITHUB_PAT"; };f' %s /workspace
`, job.Spec.Workspace.Vcs.Source)},
				Env: []v1.EnvVar{
					{
						Name:  "GITHUB_PAT",
						Value: job.Spec.Token,
					},
				},
				VolumeMounts: []v1.VolumeMount{
					{
						MountPath: "/workspace",
						Name:      "workspace",
					},
				},
			},
		},
		Volumes: []v1.Volume{
			{
				Name: "workspace",
				VolumeSource: v1.VolumeSource{
					EmptyDir: &v1.EmptyDirVolumeSource{},
				},
			},
		},
		RestartPolicy: v1.RestartPolicyNever,
	}

	return &v1.Pod{
		ObjectMeta: metav1.ObjectMeta{
			Namespace:    job.Spec.OrganizationId,
			GenerateName: "chushi-runner-",
			Labels:       map[string]string{},
		},
		Spec: podSpec,
	}
}
