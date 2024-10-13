# frozen_string_literal: true

class VcsConnection < ApplicationRecord
  include Vault::EncryptedModel
  vault_lazy_decrypt!

  vault_attribute :github_personal_access_token
  vault_attribute :github_application_secret
  vault_attribute :github_oauth_application_secret
  vault_attribute :webhook_secret

  belongs_to :organization
end
