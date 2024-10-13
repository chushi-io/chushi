class RegistryModuleVersionSerializer < ApplicationSerializer
  set_type "registry-module-versions"

  attribute :source
  attribute :version
  attribute :status

  attribute :upload_url, unless: Proc.new { |record, params|
    record.archive.present?
  } do |object|
    encrypt_upload_url({id: object.id, class: object.class.name})
  end
end