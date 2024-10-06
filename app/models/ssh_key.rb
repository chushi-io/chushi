class SshKey < ApplicationRecord
  include Vault::EncryptedModel
  vault_lazy_decrypt!

  vault_attribute :private_key
  belongs_to :organization

  before_create -> { generate_id("sshkey") }
end
