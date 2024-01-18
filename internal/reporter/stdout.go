package reporter

type Stdout struct {
}

func (s *Stdout) Receive() error {
	return nil
}
