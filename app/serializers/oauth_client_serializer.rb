class OauthClientSerializer < ApplicationSerializer
  set_type 'oauth-clients'

  attribute :created_at
  attribute :callback_url do |object|
    "https://#{Chushi.domain}/auth/#{object.auth_identifier}/callback"
  end

  attribute :connect_path do |object|
    "/auth/#{object.auth_identifier}?organization_id=1"
  end

  attribute :service_provider
  attribute :service_provider_display_name
  attribute :name
  attribute :http_url
  attribute :api_url
  attribute :key
  attribute :rsa_public_key
  attribute :organization_scoped

  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name, &:organization
  has_many :oauth_tokens, serializer: OauthTokenSerializer, id_method_name: :external_id, &:oauth_tokens

end
