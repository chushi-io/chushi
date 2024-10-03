class StateVersionSerializer < ApplicationSerializer
  singleton_class.include Rails.application.routes.url_helpers

  set_type :state_versions

  attribute :created_at
  attribute :size
  attribute :hosted_state_download_url do |object|
    api_v2_get_state_url(id: object.external_id, host: Chushi.domain, protocol: 'https')
  end

  attribute :hosted_state_upload_url do |object|
    api_v2_upload_state_url(id: object.external_id, host: Chushi.domain, protocol: 'https')
  end

  attribute :hosted_json_state_download_url do |object|
    api_v2_get_state_json_url(id: object.external_id, host: Chushi.domain, protocol: 'https')
  end

  attribute :hosted_json_state_upload_url do |object|
    api_v2_upload_state_json_url(id: object.external_id, host: Chushi.domain, protocol: 'https')
  end

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
