class OauthClient < ApplicationRecord
  before_create :set_auth_identifier

  include Vault::EncryptedModel
  vault_lazy_decrypt!

  belongs_to :organization

  vault_attribute :secret
  vault_attribute :private_key
  vault_attribute :oauth_token_string

  before_create -> { generate_id('oc') }

  def set_auth_identifier
    self.auth_identifier = SecureRandom.uuid
  end
end
