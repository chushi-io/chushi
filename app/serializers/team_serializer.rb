class TeamSerializer < ApplicationSerializer
  set_type 'teams'

  attribute :name
  attribute :sso_team_id
  attribute :users_count
  attribute :visibility
  attribute :allow_member_token_management
  attribute :permissions do |_o|
    {}
  end
  attribute :organization_access do |_o|
    {}
  end

  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name do |object|
    object.organization
  end
end
