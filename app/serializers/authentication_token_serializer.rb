# frozen_string_literal: true

class AuthenticationTokenSerializer < ApplicationSerializer
  set_type 'authentication-tokens'

  attribute :created_at
  attribute :last_used_at
  attribute :description

  attribute :token, if: proc { |_record, params|
    params[:show_token]
  } do |object|
    "#{object.external_id.delete_prefix('at-')}.#{object.token}"
  end

  attribute :expired_at
end
