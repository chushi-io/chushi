class ConfigurationVersionSerializer < ApplicationSerializer
  singleton_class.include Rails.application.routes.url_helpers

  set_type "configuration-versions"

  attribute :source
  attribute :speculative
  attribute :status
  attribute :provisional
  attribute :auto_queue_runs

  attribute :upload_url do |object|
    upload_api_v2_configuration_version_url(object, host: Chushi.domain, protocol: 'https')
  end

  # link :self, :url
  link :self do |object|
    api_v2_configuration_version_path(object)
  end

  link :download do |object|
    download_api_v2_configuration_version_path(object)
  end
end

# {
#   "data": {
#     "id": "cv-ntv3HbhJqvFzamy7",
#     "type": "configuration-versions",
#     "attributes": {
#       "error": null,
#       "error-message": null,
#       "source": "gitlab",
#       "speculative":false,
#       "status": "uploaded",
#       "status-timestamps": {},
#       "provisional": false
#     },
#     "relationships": {
#       "ingress-attributes": {
#         "data": {
#           "id": "ia-i4MrTxmQXYxH2nYD",
#           "type": "ingress-attributes"
#         },
#         "links": {
#           "related":
#             "/api/v2/configuration-versions/cv-ntv3HbhJqvFzamy7/ingress-attributes"
#         }
#       }
#     },
#     "links": {
#       "self": "/api/v2/configuration-versions/cv-ntv3HbhJqvFzamy7",
#       "download": "/api/v2/configuration-versions/cv-ntv3HbhJqvFzamy7/download"
#     }
#   }
# }