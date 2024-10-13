# frozen_string_literal: true

class RunTaskSerializer < ApplicationSerializer
  set_type :tasks

  attribute :category
  attribute :name
  attribute :url
  attribute :description
  attribute :enabled
  attribute :hmac_key

  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name, &:organization
end
