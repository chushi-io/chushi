class OauthTokenSerializer < ApplicationSerializer
  set_type 'oauth-tokens'

  attribute :service_provider_user
  attribute :has_ssh_key

  belongs_to :oauth_client, serializer: OauthClientSerializer, id_method_name: :external_id, &:oauth_client
end
