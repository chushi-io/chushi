class StateVersionSerializer < ApplicationSerializer
  singleton_class.include Rails.application.routes.url_helpers

  set_type :state_versions

  attribute :created_at
  attribute :size
  attribute :hosted_state_download_url do |object|
    encrypt_storage_url({id: object.id, class: object.class.name, file: "state"})
  end

  attribute :hosted_state_upload_url do |object|
    if object.state_file.present?
      nil
    else
      encrypt_upload_url({id: object.id, class: object.class.name, file: "state"})
    end
  end

  attribute :hosted_json_state_download_url do |object|
    encrypt_storage_url({id: object.id, class: object.class.name, file: "state.json"})
  end

  attribute :hosted_json_state_upload_url do |object|
    if object.state_json_file.present?
      nil
    else
      encrypt_upload_url({id: object.id, class: object.class.name, file: "state.json"})
    end
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
