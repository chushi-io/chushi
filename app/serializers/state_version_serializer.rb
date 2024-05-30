class StateVersionSerializer
  include JSONAPI::Serializer
  set_key_transform :dash

  set_type :state_versions
  attribute :created_at
  attribute :size
  attribute :hosted_state_download_url
  attribute :hosted_state_upload_url
  attribute :hosted_json_state_download_url
  attribute :hosted_json_state_upload_url
  attribute :status
  attribute :intermediate
  attribute :modules
  attribute :providers
  attribute :resources
  attribute :resources_processed
  attribute :serial
  attribute :state_version
  attribute :terraform_version do |object|
    object.tofu_version
  end
  attribute :vcs_commit_url
  attribute :vcs_commit_sha
end

# {
#     "data": {
#         "id": "sv-g4rqST72reoHMM5a",
#         "type": "state-versions",
#         "attributes": {
#             "created-at": "2021-06-08T01:22:03.794Z",
#             "size": 940,
#             "hosted-state-download-url": "https://archivist.terraform.io/v1/object/...",
#             "hosted-state-upload-url": null,
#             "hosted-json-state-download-url": "https://archivist.terraform.io/v1/object/...",
#             "hosted-json-state-upload-url": null,
#             "status": "finalized",
#             "intermediate": false,
#             "modules": {
#                 "root": {
#                     "null-resource": 1,
#                     "data.terraform-remote-state": 1
#                 }
#             },
#             "providers": {
#                 "provider[\"terraform.io/builtin/terraform\"]": {
#                     "data.terraform-remote-state": 1
#                 },
#                 "provider[\"registry.terraform.io/hashicorp/null\"]": {
#                     "null-resource": 1
#                 }
#             },
#             "resources": [
#                 {
#                     "name": "other_username",
#                     "type": "data.terraform_remote_state",
#                     "count": 1,
#                     "module": "root",
#                     "provider": "provider[\"terraform.io/builtin/terraform\"]"
#                 },
#                 {
#                     "name": "random",
#                     "type": "null_resource",
#                     "count": 1,
#                     "module": "root",
#                     "provider": "provider[\"registry.terraform.io/hashicorp/null\"]"
#                 }
#             ],
#             "resources-processed": true,
#             "serial": 9,
#             "state-version": 4,
#             "terraform-version": "0.15.4",
#             "vcs-commit-url": "https://gitlab.com/my-organization/terraform-test/-/commit/abcdef12345",
#             "vcs-commit-sha": "abcdef12345"
#         },
#         "relationships": {
#             "run": {
#                 "data": {
#                     "id": "run-YfmFLWpgTv31VZsP",
#                     "type": "runs"
#                 }
#             },
#             "created-by": {
#                 "data": {
#                     "id": "user-onZs69ThPZjBK2wo",
#                     "type": "users"
#                 },
#                 "links": {
#                     "self": "/api/v2/users/user-onZs69ThPZjBK2wo",
#                     "related": "/api/v2/runs/run-YfmFLWpgTv31VZsP/created-by"
#                 }
#             },
#             "workspace": {
#                 "data": {
#                     "id": "ws-noZcaGXsac6aZSJR",
#                     "type": "workspaces"
#                 }
#             },
#             "outputs": {
#                 "data": [
#                     {
#                         "id": "wsout-V22qbeM92xb5mw9n",
#                         "type": "state-version-outputs"
#                     },
#                     {
#                         "id": "wsout-ymkuRnrNFeU5wGpV",
#                         "type": "state-version-outputs"
#                     },
#                     {
#                         "id": "wsout-v82BjkZnFEcscipg",
#                         "type": "state-version-outputs"
#                     }
#                 ]
#             }
#         },
#         "links": {
#             "self": "/api/v2/state-versions/sv-g4rqST72reoHMM5a"
#         }
#     }
# }