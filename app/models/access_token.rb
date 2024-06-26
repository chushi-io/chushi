class AccessToken < ApplicationRecord
  belongs_to :token_authable, polymorphic: true
  before_create :generate_access_token

  def generate_access_token
    self.token = SecureRandom::base58(48)
  end
end
