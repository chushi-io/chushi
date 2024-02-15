package agent

import (
	"context"
	"errors"
	"fmt"
	"github.com/chushi-io/chushi/pkg/sdk"
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
	Config *Config
	Sdk    *sdk.Sdk
	sinks  []io.Writer
}

func New(client *kubernetes.Clientset, sdk *sdk.Sdk, conf *Config) (*Agent, error) {
	return &Agent{
		Client: client,
		Sdk:    sdk,
		Config: conf,
	}, nil
}

// For now, this just queries the current list of runs,
// and exists. However, it should query the API (or stream)
// and emit runners as needed
func (a *Agent) Run() error {
	runs, err := a.Sdk.Runs().List(&sdk.ListRunsParams{
		AgentId: a.Config.GetAgentId(),
		Status:  "pending",
	})
	if err != nil {
		return err
	}
	for _, run := range runs.Runs {
		if err := a.handle(run); err != nil {
			a.Sdk.Runs().Update(&sdk.UpdateRunParams{
				RunId:  run.Id,
				Status: "failed",
			})
			return err
		}
	}
	return nil
}

func (a *Agent) handle(run sdk.Run) error {
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

	url, err := a.Sdk.Runs().PresignedUrl(&sdk.GeneratePresignedUrlParams{
		RunId: run.Id,
	})
	if err != nil {
		return err
	}

	token, err := a.Sdk.Tokens().CreateRunnerToken(&sdk.CreateRunnerTokenParams{})
	if err != nil {
		return err
	}

	if _, err := a.Sdk.Runs().Update(&sdk.UpdateRunParams{
		RunId:  run.Id,
		Status: "running",
	}); err != nil {
		return err
	}

	pod, err := a.launchPod(run, ws.Workspace, token, url.Url)
	if err != nil {
		return err
	}

	fmt.Println(pod.Name)

	success, err := a.waitForPodCompletion(pod)
	if err != nil {
		return err
	}

	if !success {
		return errors.New("workspace failed")
	}

	podLogOpts := v1.PodLogOptions{}
	req := a.Client.CoreV1().Pods(pod.Namespace).GetLogs(pod.Name, &podLogOpts)
	podLogs, err := req.Stream(context.TODO())
	if err != nil {
		return err
	}
	defer podLogs.Close()
	if err = a.PollLogs(podLogs); err != nil {
		return err
	}

	// Lastly, post updates back to the run
	_, err = a.Sdk.Runs().Update(&sdk.UpdateRunParams{
		RunId:  run.Id,
		Status: "completed",
	})
	return err
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

func (a *Agent) launchPod(run sdk.Run, workspace sdk.Workspace, token *sdk.CreateRunnerTokenResponse, presignedUrl string) (*v1.Pod, error) {
	podManifest := a.podSpecForRun(run, workspace, token, presignedUrl)
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

func (a *Agent) podSpecForRun(run sdk.Run, workspace sdk.Workspace, token *sdk.CreateRunnerTokenResponse, presignedUrl string) *v1.Pod {
	args := []string{
		"runner",
		fmt.Sprintf("-d=%s", workspace.Vcs.WorkingDirectory),
		"-v=1.6.6",
		run.Operation,
	}

	autoMount := false
	podSpec := v1.PodSpec{
		AutomountServiceAccountToken: &autoMount,
		Containers: []v1.Container{
			// Actual run container
			{
				Name:            "chushi",
				Image:           a.Config.GetImage(),
				ImagePullPolicy: "Never",
				Command:         []string{"/chushi"},
				Args:            args,
				Env: []v1.EnvVar{
					{
						Name:  "CHUSHI_API_URL",
						Value: a.Config.GetApiUrl(),
					},
					{
						Name:  "CHUSHI_ORGANIZATION",
						Value: a.Sdk.OrganizationId,
					},
					{
						Name:  "CHUSHI_RUN_ID",
						Value: run.Id,
					},
					{
						Name:  "RUNNER_TOKEN",
						Value: token.AccessToken,
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
`, workspace.Vcs.Source)},
				Env: []v1.EnvVar{
					{
						Name:  "GITHUB_PAT",
						Value: "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",
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
			Namespace:    a.Config.GetNamespace(),
			GenerateName: "chushi-runner-",
			Labels:       map[string]string{},
		},
		Spec: podSpec,
	}
}
