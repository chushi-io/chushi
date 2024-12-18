# frozen_string_literal: true

class ProviderSerializer < ApplicationSerializer
  set_type 'registry-providers'

  attribute :name
  attribute :namespace
  attribute :registry_name do |_object|
    'private'
  end
  attribute :created_at
  attribute :updated_at
  attribute :permissions do |_object|
    {}
  end

  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name, &:organization
end
