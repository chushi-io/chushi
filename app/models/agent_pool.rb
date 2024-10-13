class AgentPool < ApplicationRecord
  belongs_to :organization
  has_many :access_tokens, as: :token_authable

  before_create :generate_credentials
  before_create -> { generate_id('apool') }

  def generate_credentials
    self.api_key = SecureRandom.hex
    self.api_secret = SecureRandom.hex
  end
end
