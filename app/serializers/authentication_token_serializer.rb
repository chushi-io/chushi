class AuthenticationTokenSerializer < ApplicationSerializer
  set_type "authentication-tokens"

  attribute :created_at
  attribute :last_used_at
  attribute :description

  attribute :token, if: Proc.new { |record, params|
    params[:show_token]
  }

  attribute :expired_at

end
