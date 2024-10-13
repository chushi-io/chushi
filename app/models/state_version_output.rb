class StateVersionOutput < ApplicationRecord
  belongs_to :state_version
  include Vault::EncryptedModel
  vault_lazy_decrypt!

  vault_attribute :value

  before_create -> { generate_id('wsout') }
end
