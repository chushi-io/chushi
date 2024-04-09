package driver

import (
	"errors"
	apiv1 "github.com/chushi-io/chushi/gen/api/v1"
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/go-git/go-git/v5/plumbing/transport/http"
	"os"
)

type Job struct {
	Spec   *JobSpec
	Status *JobStatus
}

type JobSpec struct {
	OrganizationId string
	Image          string
	Run            *apiv1.Run
	Workspace      *apiv1.Workspace
	Token          string
	Credentials    string
	Variables      []*apiv1.Variable
}

func NewJob(spec *JobSpec) *Job {
	return &Job{
		Spec: spec,
		Status: &JobStatus{
			Metadata: map[string]string{},
		},
	}
}

type JobStatus struct {
	Metadata map[string]string
	State    string
}

func (job *Job) GetMetadata(key string) (string, error) {
	if val, ok := job.Status.Metadata[key]; ok {
		return val, nil
	}
	return "", errors.New("metadata key not found")
}

type Driver interface {
	Start(job *Job) (*Job, error)
	Wait(job *Job) (*Job, error)
	Cleanup(job *Job) error
}

func cloneGitRepo(runId string, source string, branch string, token string) (string, error) {
	dir, err := os.MkdirTemp(os.TempDir(), runId)
	if err != nil {
		return "", err
	}
	r, err := git.PlainClone(dir, false, &git.CloneOptions{
		Auth: &http.BasicAuth{
			Username: "chushi",
			Password: token,
		},
		URL:      source,
		Progress: os.Stdout,
	})

	if err != nil {
		return "", err
	}

	if branch != "" {
		// Switch to a specific branch
		w, err := r.Worktree()
		if err != nil {
			return "", err
		}
		branchRefName := plumbing.NewBranchReferenceName(branch)
		branchCoOpts := git.CheckoutOptions{
			Branch: plumbing.ReferenceName(branchRefName),
			Force:  true,
		}
		if err := w.Checkout(&branchCoOpts); err != nil {
			return "", err
			//mirrorRemoteBranchRefSpec := fmt.Sprintf("refs/heads/%s:refs/heads/%s", branch, branch)
			//err = fetchOrigin(r, mirrorRemoteBranchRefSpec)
			//CheckIfError(err)
			//
			//err = w.Checkout(&branchCoOpts)
			//CheckIfError(err)
		}
	}

	return dir, nil
}
