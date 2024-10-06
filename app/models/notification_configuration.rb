class NotificationConfiguration < ApplicationRecord
  include Vault::EncryptedModel
  vault_lazy_decrypt!

  vault_attribute :token
  has_many :notification_delivery_responses

  belongs_to :workspace
  before_create -> { generate_id("nc") }
end
