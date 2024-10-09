class AccessToken < ApplicationRecord
  include Vault::EncryptedModel
  vault_lazy_decrypt!

  vault_attribute :token
  belongs_to :token_authable, polymorphic: true
  before_create :generate_access_token
  before_create -> { generate_id("at") }

  # belongs_to :user, optional: true
  # belongs_to :agent_pool, optional: true
  # belongs_to :team, optional: true
  # belongs_to :organization, optional: true

  def generate_access_token
    self.token = SecureRandom::base58(48)
  end


end
