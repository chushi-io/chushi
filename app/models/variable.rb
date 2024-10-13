# frozen_string_literal: true

class Variable < ApplicationRecord
  include Vault::EncryptedModel
  vault_lazy_decrypt!

  vault_attribute :value
  before_create -> { generate_id('var') }
end
