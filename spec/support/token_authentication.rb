# frozen_string_literal: true

module TokenAuthentication
  def auth_headers(token)
    token_id = token.external_id.delete_prefix('at-')
    header_token = "#{token_id}.#{token.token}"
    { Authorization: "Bearer #{header_token}" }
  end
end
