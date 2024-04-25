package response

import (
	"fmt"
	"github.com/chushi-io/chushi/internal/resource/run"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/gin-gonic/gin"
)

func WorkspaceStateVersion(ws *workspaces.Workspace) gin.H {
	return gin.H{
		"data": gin.H{
			"id":   ws.ID,
			"type": "state-versions",
			"attributes": gin.H{
				"vcs-commit-sha":                 "",
				"vcs-commit-url":                 "",
				"created-at":                     "2018-07-12T20:32:01.490Z",
				"hosted-state-download-url":      "https://archivist.chushi.io.io/v1/object/f55b739b-ff03-4716-b436-726466b96dc4",
				"hosted-json-state-download-url": "https://archivist.chushi.io.io/v1/object/4fde7951-93c0-4414-9a40-f3abc4bac490",
				"hosted-state-upload-url":        "",
				"hosted-json-state-upload-url":   "",
				"status":                         "finalized",
				"intermediate":                   true,
				"serial":                         1,
			},
			"links": gin.H{},
		},
	}
}

func WorkspaceConfigurationVersion(ws *workspaces.Workspace, version *workspaces.ConfigurationVersion) gin.H {
	return gin.H{
		"data": gin.H{
			"id":   version.ID,
			"type": "configuration-versions",
			"attributes": gin.H{
				"auto-queue-runs":   true,
				"error":             "null",
				"error-message":     "null",
				"source":            version.Source,
				"speculative":       version.Speculative,
				"status":            version.Status,
				"status-timestamps": gin.H{},
				"upload-url":        fmt.Sprintf("https://caring-foxhound-whole.ngrok-free.app/api/v1/workspaces/%s/configuration-versions/%s", ws.ID, version.ID),
				"provisional":       version.Provisional,
			},
			"relationships": gin.H{},
		},
	}
}

func WorkspaceCurrentStateVersion(ws *workspaces.Workspace) gin.H {
	return gin.H{
		"data": gin.H{
			"id":   ws.ID,
			"type": "state-versions",
			"attributes": gin.H{
				"created-at":                     "2021-06-08T01:22:03.794Z",
				"size":                           940,
				"hosted-state-download-url":      fmt.Sprintf("https://caring-foxhound-whole.ngrok-free.app/%s/%s/state", ws.OrganizationID, ws.ID),
				"hosted-state-upload-url":        "",
				"hosted-json-state-download-url": "",
				"hosted-json-state-upload-url":   "",
				"status":                         "finalized",
				"intermediate":                   false,
				"modules": gin.H{
					"root": gin.H{
						"null-resource":               1,
						"data.terraform-remote-state": 1,
					},
				},
				"providers":           gin.H{},
				"resources":           []gin.H{},
				"resources-processed": true,
				"serial":              9,
				"state-version":       4,
				"terraform-version":   "0.15.4",
				"vcs-commit-url":      "https://gitlab.com/my-organization/terraform-test/-/commit/abcdef12345",
				"vcs-commit-sha":      "abcdef12345",
			},
			"relationships": gin.H{
				"created-by": gin.H{
					"data":  gin.H{},
					"links": gin.H{},
				},
				"workspace": gin.H{
					"data": gin.H{
						"id":   ws.ID,
						"type": "workspaces",
					},
				},
				"outputs": gin.H{
					"data": []gin.H{},
				},
			},
			"links": gin.H{},
		},
	}
}

func WorkspaceRun(ws *workspaces.Workspace, run *run.Run) gin.H {
	return gin.H{
		"data": gin.H{
			"id":   run.ID,
			"type": "runs",
			"attributes": gin.H{
				"actions": gin.H{
					"is-cancelable":       true,
					"is-confirmable":      false,
					"is-discardable":      false,
					"is-force-cancelable": false,
				},
				//"canceled-at": null,
				"created-at":              run.CreatedAt.Format("2006-01-02T15:04:05.000Z"),
				"has-changes":             false,
				"auto-apply":              false,
				"allow-empty-apply":       false,
				"allow-config-generation": false,
				"is-destroy":              false,
				"message":                 "Custom message",
				"plan-only":               false,
				"source":                  "tfe-api",
				"status-timestamps":       gin.H{},
				"status":                  run.Status,
				"trigger-reason":          "manual",
				"permissions": gin.H{
					"can-apply":                 true,
					"can-cancel":                true,
					"can-comment":               true,
					"can-discard":               true,
					"can-force-execute":         true,
					"can-force-cancel":          true,
					"can-override-policy-check": true,
				},
				"refresh":       false,
				"refresh-only":  false,
				"replace-addrs": []string{},
				"save-plan":     false,
				"target-addrs":  []string{},
				"variables":     []gin.H{},
			},
			"relationships": gin.H{
				// For now, we'll simply map the plan and
				// apply relationships to the run itself
				"plan": gin.H{
					"data": gin.H{
						"type": "plans",
						"id":   run.ID,
					},
				},
				"apply": gin.H{
					"data": gin.H{
						"type": "applies",
						"id":   run.ID,
					},
				},
			},
			"links": gin.H{
				"self": fmt.Sprintf("/api/v1/runs/%s", run.ID),
			},
		},
	}
}

func WorkspaceRuns(runs []run.Run) gin.H {
	var data []gin.H
	for _, r := range runs {
		data = append(data, gin.H{
			"id":   r.ID,
			"type": "runs",
			"attributes": gin.H{
				"actions": gin.H{
					"is-cancelable":       true,
					"is-confirmable":      false,
					"is-discardable":      false,
					"is-force-cancelable": false,
				},
				//"canceled-at": null,
				"created-at":              r.CreatedAt.Format("2006-01-02T15:04:05.000Z"),
				"has-changes":             false,
				"auto-apply":              false,
				"allow-empty-apply":       false,
				"allow-config-generation": false,
				"is-destroy":              false,
				"message":                 "Custom message",
				"plan-only":               false,
				"source":                  "tfe-api",
				"status-timestamps":       gin.H{},
				"status":                  r.Status,
				"trigger-reason":          "manual",
				"permissions": gin.H{
					"can-apply":                 true,
					"can-cancel":                true,
					"can-comment":               true,
					"can-discard":               true,
					"can-force-execute":         true,
					"can-force-cancel":          true,
					"can-override-policy-check": true,
				},
				"refresh":       false,
				"refresh-only":  false,
				"replace-addrs": []string{},
				"save-plan":     false,
				"target-addrs":  []string{},
				"variables":     []gin.H{},
			},
			"relationships": gin.H{},
			"links": gin.H{
				"self": fmt.Sprintf("/api/v1/runs/%s", r.ID),
			},
		})
	}
	return gin.H{
		"data": data,
	}
}

func RunAsPlan(r *run.Run) gin.H {
	return gin.H{
		"data": gin.H{
			"id":   r.ID,
			"type": "plans",
			"attributes": gin.H{
				"execution-details": gin.H{
					"mode": "remote",
				},
				"generated-configuration": false,
				"has-changes":             true,
				"resource-additions":      r.Add,
				"resource-changes":        r.Change,
				"resource-destructions":   r.Destroy,
				"resource-imports":        0,
				"status":                  r.Status,
				"status-timestamps": gin.H{
					"queued-at":   "2018-07-02T22:29:53+00:00",
					"pending-at":  "2018-07-02T22:29:53+00:00",
					"started-at":  "2018-07-02T22:29:54+00:00",
					"finished-at": "2018-07-02T22:29:58+00:00",
				},
				"log-read-url": fmt.Sprintf("https://caring-foxhound-whole.ngrok-free.app/api/v1/runs/%s/logs", r.ID),
			},
			"relationships": gin.H{},
			"links":         gin.H{},
		},
	}
}
