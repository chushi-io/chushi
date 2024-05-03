class Run < ApplicationRecord
  belongs_to :organization
  belongs_to :workspace

  belongs_to :configuration_version, optional: true
  belongs_to :plan, optional: true
  belongs_to :apply, optional: true

  def as_json(options = nil)
    {
      "id":   self.id,
      "type": "runs",
      "attributes": {
        "actions": {
          "is-cancelable":       true,
          "is-confirmable":      false,
          "is-discardable":      false,
          "is-force-cancelable": false,
        },
        "canceled-at": nil,
        "created-at":              self.created_at,
        "has-changes":             false,
        "auto-apply":              false,
        "allow-empty-apply":       false,
        "allow-config-generation": false,
        "is-destroy":              false,
        "message":                 self.message,
        "plan-only":               false,
        "source":                  "tfe-api",
        "status-timestamps":       {},
        "status":                  self.status,
        "trigger-reason":          "manual",
          "permissions": {
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
        "replace-addrs": [],
        "save-plan":     false,
        "target-addrs":  [],
        "variables":     [],
      },
      "relationships": {},
      "links": {
        "self": "/api/v1/runs/#{self.id}",
      },
    }
    super
  end
end
