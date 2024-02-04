package agent

import (
	"encoding/json"
	"fmt"
	"github.com/robwittman/chushi/pkg/sdk"
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

	fmt.Printf(
		"Add: %d; Change: %d; Remove: %d;\n",
		summary.Changes.Add,
		summary.Changes.Change,
		summary.Changes.Remove,
	)
	err := sink.Sdk.UpdateRun(sink.RunId, map[string]interface{}{
		"add":    summary.Changes.Add,
		"change": summary.Changes.Change,
		"remove": summary.Changes.Remove,
	})
	return 0, err
}
