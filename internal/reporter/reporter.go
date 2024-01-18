package reporter

type Reporter struct {
	Sinks map[string]Sink
}

type Sink interface {
	Receive() error
}

func (r *Reporter) Report() map[string]error {
	errors := map[string]error{}
	for name, sink := range r.Sinks {
		if err := sink.Receive(); err != nil {
			errors[name] = err
		}
	}
	return errors
}
