class RegistryModuleSerializer < ApplicationSerializer
  set_type 'registry-modules'

  attribute :name
  attribute :namespace
  attribute :provider
  attribute :status

  attribute :version_statuses do |object|
    object.registry_module_versions.map do |item|
      { version: item.version, status: item.status }
    end
  end

  attribute :created_at
  attribute :updated_at
  attribute :registry_name do |_object|
    'private'
  end
  attribute :permissions do |_object|
    {}
  end

  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name do |object|
    object.organization
  end
end
