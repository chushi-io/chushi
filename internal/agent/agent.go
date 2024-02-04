package agent

import (
	"context"
	"errors"
	"fmt"
	"github.com/robwittman/chushi/pkg/sdk"
	"io"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"log"
	"strings"
	"time"
)

type Agent struct {
	Client *kubernetes.Clientset
	Sdk    *sdk.Sdk
	sinks  []io.Writer
}

func New(client *kubernetes.Clientset, sdk *sdk.Sdk) (*Agent, error) {
	return &Agent{
		Client: client,
		Sdk:    sdk,
	}, nil
}

func (a *Agent) Run() error {
	fmt.Println("Running agent...")
	// Subscribe to whichever endpoint for getting queued runs,
	// and handle events
	select {}
}

func (a *Agent) Handle(run sdk.Run) error {
	a.sinks = []io.Writer{ChangeSink{
		RunId: run.Id,
		Sdk:   a.Sdk,
	}}
	ws, err := a.Sdk.GetWorkspace(run.WorkspaceId)
	if err != nil {
		return err
	}

	// TODO: Should we just kick off the job, and let the
	// runner itself just fail if its locked?
	if ws.Workspace.Locked {
		return errors.New("workspace is already locked")
	}

	pod, err := a.launchPod(run, ws.Workspace)
	if err != nil {
		return err
	}

	success, err := a.waitForPodCompletion(pod)
	if err != nil {
		return err
	}

	if !success {
		// Do something with the error
		return errors.New("workspace failed")
	}

	podLogOpts := v1.PodLogOptions{}
	req := a.Client.CoreV1().Pods(pod.Namespace).GetLogs(pod.Name, &podLogOpts)
	podLogs, err := req.Stream(context.TODO())
	if err != nil {
		log.Fatal(err)
	}
	defer podLogs.Close()
	if err = a.PollLogs(podLogs); err != nil {
		return err
	}

	// Lastly, post updates back to the run

	return nil
}

func (a *Agent) waitForPodCompletion(pod *v1.Pod) (bool, error) {
loop:
	for {
		pod, err := a.Client.CoreV1().
			Pods(pod.Namespace).
			Get(context.TODO(), pod.Name, metav1.GetOptions{})
		if err != nil {
			log.Fatal(err)
		}

		switch pod.Status.Phase {
		case v1.PodSucceeded:
			break loop
		case v1.PodFailed:
			return false, errors.New(pod.Status.Message)
		case v1.PodPending:
		case v1.PodRunning:
			time.Sleep(time.Second)
		}
	}

	return true, nil
}

func (a *Agent) launchPod(run sdk.Run, workspace sdk.Workspace) (*v1.Pod, error) {
	podManifest := a.podSpecForRun()
	return a.Client.CoreV1().
		Pods("default").
		Create(context.TODO(), podManifest, metav1.CreateOptions{})
}

func (a *Agent) RegisterSink(sink io.Writer) {
	a.sinks = append(a.sinks, sink)
}

func (a *Agent) PollLogs(closer io.ReadCloser) error {
	_, err := io.Copy(a, closer)
	return err
}

func (a *Agent) Write(p []byte) (int, error) {
	// TODO: We'll probably have to do some buffering
	// here or something. Depending on the length of the
	// chunk, we may end up with partial lines
	lines := strings.Split(string(p), "\n")
	for _, line := range lines {
		_ = a.writeLine(line)
	}
	return len(p), nil
}

func (a *Agent) writeLine(line string) error {
	for _, sink := range a.sinks {
		sink.Write([]byte(line))
	}
	return nil
}

func (a *Agent) podSpecForRun() *v1.Pod {
	podSpec := v1.PodSpec{
		Containers: []v1.Container{
			// Actual run container
			{
				Name:            "chushi",
				Image:           "chushi",
				ImagePullPolicy: "Never",
				Command:         []string{"/chushi"},
				Args: []string{
					"runner",
					"-d=/workspace/testdata",
					"plan",
					"-v=1.6.6",
				},
				VolumeMounts: []v1.VolumeMount{
					{
						MountPath: "/workspace",
						Name:      "workspace",
					},
				},
			},
		},
		InitContainers: []v1.Container{
			{
				Name:  "git",
				Image: "alpine/git",
				Args: []string{
					"clone",
					"https://github.com/robwittman/chushi",
					"/workspace",
				},
				VolumeMounts: []v1.VolumeMount{
					{
						MountPath: "/workspace",
						Name:      "workspace",
					},
				},
			},
			// Container to download VCS repo
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
			Namespace:    "default",
			GenerateName: "chushi-runner-",
			Labels:       map[string]string{},
		},
		Spec: podSpec,
	}
}
