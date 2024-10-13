# frozen_string_literal: true

class OrganizationMembershipSerializer < ApplicationSerializer
  set_type 'organization-memberships'

  attribute :status
  attribute :email
  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name, &:organization

  belongs_to :user, serializer: UserSerializer, id_method_name: :external_id, &:user
end
