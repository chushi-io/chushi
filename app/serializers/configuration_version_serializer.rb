class ConfigurationVersionSerializer
  singleton_class.include Rails.application.routes.url_helpers

  include JSONAPI::Serializer

  set_type "configuration-versions"
  set_key_transform :dash

  attribute :source
  attribute :speculative
  attribute :status
  attribute :provisional
  attribute :auto_queue_runs

  attribute :upload_url do |object|
    upload_api_v1_configuration_version_url(object, host: 'caring-foxhound-whole.ngrok-free.app', protocol: 'https')
  end

  # link :self, :url
  link :self do |object|
    api_v1_configuration_version_path(object)
  end

  link :download do |object|
    download_api_v1_configuration_version_path(object)
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