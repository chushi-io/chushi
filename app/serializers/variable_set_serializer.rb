# frozen_string_literal: true

class VariableSetSerializer < ApplicationSerializer
  set_type 'varsets'

  attribute :name
  attribute :description
  attribute :global
  attribute :priority

  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name, &:organization
end
