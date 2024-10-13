# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  set_type 'users'

  attribute :email
  attribute :username, &:email
  attribute :is_service_account do |_o|
    false
  end
  attribute :avatar_url do |_o|
    ''
  end
  attribute :v2_only do |_o|
    false
  end
  attribute :permissions do |_o|
    {
      'can-create-organizations': true,
      'can-change-email': true,
      'can-change-username': true
    }
  end

  # has_many :teams, serializer: TeamSerializer, id_method_name: :external_id do |object|
  #   object.teams
  # end
end
