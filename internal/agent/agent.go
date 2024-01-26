package agent

import (
	"fmt"
	"k8s.io/client-go/kubernetes"
)

type Agent struct {
	client *kubernetes.Clientset
}

func New(client *kubernetes.Clientset) (*Agent, error) {
	return &Agent{client}, nil
}

func (a *Agent) Run() error {
	fmt.Println("Running agent...")
	// Subscribe to whichever endpoint for getting queued runs,
	// and handle events
	select {}
}

func (a *Agent) launchPod() {

}
