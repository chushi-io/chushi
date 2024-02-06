package types

import "errors"

type RunStatus string

const (
	RunStatusPending    RunStatus = "pending"
	RunStatusRunning              = "running"
	RunStatusPlanned              = "planned"
	RunStatusCompleted            = "completed"
	RunStatusFailed               = "failed"
	RunStatusSuperseded           = "superseded"
	RunStatusCancelled            = "cancelled"
)

func ToRunStatus(input string) (RunStatus, error) {
	switch input {
	case "pending":
		return RunStatusPending, nil
	case "running":
		return RunStatusRunning, nil
	case "planned":
		return RunStatusPlanned, nil
	case "completed":
		return RunStatusCompleted, nil
	case "failed":
		return RunStatusFailed, nil
	case "superseded":
		return RunStatusSuperseded, nil
	case "cancelled":
		return RunStatusCancelled, nil
	default:
		return "", errors.New("invalid run status provided")
	}
}

func (rs RunStatus) String() (string, error) {
	switch rs {
	case RunStatusPending:
		return "pending", nil
	case RunStatusRunning:
		return "running", nil
	case RunStatusPlanned:
		return "planned", nil
	case RunStatusCompleted:
		return "completed", nil
	case RunStatusFailed:
		return "failed", nil
	case RunStatusSuperseded:
		return "superseded", nil
	case RunStatusCancelled:
		return "cancelled", nil
	default:
		return "", errors.New("invalid run status provided")
	}
}
