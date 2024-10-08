class UserSerializer < ApplicationSerializer
  set_type "users"

  attribute :email
  attribute :username do |o| o.email end
  attribute :is_service_account do |o| false end
  attribute :avatar_url do |o| "" end
  attribute :v2_only do |o| false end
  attribute :permissions do |o| {
    "can-create-organizations": true,
    "can-change-email": true,
    "can-change-username": true,
  } end

  # has_many :teams, serializer: TeamSerializer, id_method_name: :external_id do |object|
  #   object.teams
  # end
end
