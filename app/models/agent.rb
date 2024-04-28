class Agent < ApplicationRecord
  before_create :generate_credentials
  belongs_to :organization

  def generate_credentials
    self.api_key = SecureRandom.hex
    self.api_secret = SecureRandom.hex
  end
end
