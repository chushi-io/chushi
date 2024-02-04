package agent

import (
	"fmt"
	"io"
	"k8s.io/client-go/kubernetes"
	"strings"
)

type Agent struct {
	Client *kubernetes.Clientset
	sinks  []io.Writer
	stream io.ReadCloser
}

func New(client *kubernetes.Clientset) (*Agent, error) {
	return &Agent{
		Client: client,
	}, nil
}

func (a *Agent) Run() error {
	fmt.Println("Running agent...")
	// Subscribe to whichever endpoint for getting queued runs,
	// and handle events
	select {}
}

func (a *Agent) launchPod() {

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
