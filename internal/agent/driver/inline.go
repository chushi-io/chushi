package driver

type Inline struct {
}

func (i Inline) Start(job *Job) (*Job, error) {
	// Create a temp directory
	// Clone the git repo
	// Start the docker container
	// Mount the volume
	return nil, nil
}

func (i Inline) Wait(job *Job) (*Job, error) {
	return nil, nil
}

func (i Inline) Cleanup(job *Job) error {
	return nil
}
