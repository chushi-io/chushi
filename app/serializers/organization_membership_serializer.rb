class OrganizationMembershipSerializer < ApplicationSerializer
  set_type 'organization-memberships'

  attribute :status
  attribute :email
  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name do |object|
    object.organization
  end

  belongs_to :user, serializer: UserSerializer, id_method_name: :external_id do |object|
    object.user
  end
end
