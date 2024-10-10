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

  attribute :upload_url, unless: Proc.new { |record, params|
    record.archive.present?
  } do |object|
    encrypt_upload_url({id: object.id, class: object.class.name})
  end

  # link :self, :url
  link :self do |object|
    api_v2_configuration_version_path(object)
  end

  link :download do |object|
    if object.archive.present?
      download_api_v2_configuration_version_path(object)
    end
  end
end
