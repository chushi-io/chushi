package agent

import (
	"encoding/json"
	"github.com/chushi-io/chushi/pkg/sdk"
)

type ChangeSink struct {
	Sdk   *sdk.Sdk
	RunId string
}

type ChangeSummary struct {
	Type    string              `json:"type"`
	Changes ChangeSummaryChange `json:"changes"`
}

type ChangeSummaryChange struct {
	Add       int    `json:"add"`
	Change    int    `json:"change"`
	Remove    int    `json:"remove"`
	Import    int    `json:"import"`
	Operation string `json:"operation"`
}

func (sink ChangeSink) Write(p []byte) (int, error) {
	var summary ChangeSummary
	if err := json.Unmarshal(p, &summary); err != nil {
		return 0, err
	}

	if summary.Type != "change_summary" {
		return 0, nil
	}

	_, err := sink.Sdk.Runs().Update(&sdk.UpdateRunParams{
		RunId:   sink.RunId,
		Add:     summary.Changes.Add,
		Change:  summary.Changes.Change,
		Destroy: summary.Changes.Remove,
	})
	return 0, err
}
