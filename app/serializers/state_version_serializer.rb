class StateVersionSerializer
  singleton_class.include Rails.application.routes.url_helpers

  include JSONAPI::Serializer
  set_key_transform :dash

  set_type :state_versions
  attribute :created_at
  attribute :size
  attribute :hosted_state_download_url do |object|
    puts object.inspect
    api_v1_state_version_state_url(object, host: 'caring-foxhound-whole.ngrok-free.app', protocol: 'https')
  end

  attribute :hosted_state_upload_url do |object|
    api_v1_state_version_state_url(object, host: 'caring-foxhound-whole.ngrok-free.app', protocol: 'https')
  end

  attribute :hosted_json_state_download_url do |object|
    api_v1_state_version_state_json_url(object, host: 'caring-foxhound-whole.ngrok-free.app', protocol: 'https')
  end

  attribute :hosted_json_state_upload_url do |object|
    api_v1_state_version_state_json_url(object, host: 'caring-foxhound-whole.ngrok-free.app', protocol: 'https')
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
