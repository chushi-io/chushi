# frozen_string_literal: true

class ConfigurationVersionSerializer < ApplicationSerializer
  singleton_class.include Rails.application.routes.url_helpers

  set_type 'configuration-versions'

  attribute :source
  attribute :speculative
  attribute :status
  attribute :provisional
  attribute :auto_queue_runs

  attribute :upload_url, unless: proc { |record, _params|
    record.archive.present?
  } do |object|
    EncryptedStorage.upload_url({ id: object.id, class: object.class.name })
  end

  # link :self, :url
  link :self do |object|
    api_v2_configuration_version_path(object)
  end

  link :download do |object|
    download_api_v2_configuration_version_path(object)
  end
end
