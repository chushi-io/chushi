class PlanSerializer
  singleton_class.include Rails.application.routes.url_helpers

  include JSONAPI::Serializer

  set_type :plans
  set_key_transform :dash
  attributes

  attribute :execution_details do |object|
    {
      mode: object.execution_mode
    }
  end

  attribute :has_changes
  attribute :resource_additions
  attribute :resource_changes
  attribute :resource_destructions
  attribute :resource_imports
  attribute :status
  attribute :log_read_url do |object|
    logs_api_v1_plan_url(object, host: 'caring-foxhound-whole.ngrok-free.app', protocol: 'https')
  end

end

# {
#   "data": {
#     "id": "plan-8F5JFydVYAmtTjET",
#     "type": "plans",
#     "attributes": {
#       "execution-details": {
#         "mode": "remote",
#       },
#       "generated-configuration": false,
#       "has-changes": true,
#       "resource-additions": 0,
#       "resource-changes": 1,
#       "resource-destructions": 0,
#       "resource-imports": 0,
#       "status": "finished",
#       "status-timestamps": {
#         "queued-at": "2018-07-02T22:29:53+00:00",
#         "pending-at": "2018-07-02T22:29:53+00:00",
#         "started-at": "2018-07-02T22:29:54+00:00",
#         "finished-at": "2018-07-02T22:29:58+00:00"
#       },
#       "log-read-url": "https://archivist.terraform.io/v1/object/dmF1bHQ6djE6OFA1eEdlSFVHRSs4YUcwaW83a1dRRDA0U2E3T3FiWk1HM2NyQlNtcS9JS1hHN3dmTXJmaFhEYTlHdTF1ZlgxZ2wzVC9kVTlNcjRPOEJkK050VFI3U3dvS2ZuaUhFSGpVenJVUFYzSFVZQ1VZYno3T3UyYjdDRVRPRE5pbWJDVTIrNllQTENyTndYd1Y0ak1DL1dPVlN1VlNxKzYzbWlIcnJPa2dRRkJZZGtFeTNiaU84YlZ4QWs2QzlLY3VJb3lmWlIrajF4a1hYZTlsWnFYemRkL2pNOG9Zc0ZDakdVMCtURUE3dDNMODRsRnY4cWl1dUN5dUVuUzdnZzFwL3BNeHlwbXNXZWRrUDhXdzhGNnF4c3dqaXlZS29oL3FKakI5dm9uYU5ZKzAybnloREdnQ3J2Rk5WMlBJemZQTg"
#     },
#     "relationships": {
#       "state-versions": {
#         "data": []
#       }
#     },
#     "links": {
#       "self": "/api/v2/plans/plan-8F5JFydVYAmtTjET",
#       "json-output": "/api/v2/plans/plan-8F5JFydVYAmtTjET/json-output"
#     }
#   }
# }