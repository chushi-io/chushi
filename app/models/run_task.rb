class RunTask < ApplicationRecord
  include Vault::EncryptedModel
  vault_lazy_decrypt!

  vault_attribute :hmac_key

  belongs_to :organization

  before_create -> { generate_id('task') }
end
