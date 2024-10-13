require 'vault/rails'

Vault::Rails.configure do |vault|
  if ENV.has_key?('CI')
    vault.enabled = false
  else
    vault.enabled = Rails.env.production?
    vault.application = ENV.fetch('VAULT_APP', 'chushi')

    # Set up approle configuration
    if Rails.env.production?
      vault.namespace = ENV.fetch('VAULT_NAMESPACE', 'admin')
      vault.auth.approle(ENV.fetch('VAULT_ROLE_ID', ''), ENV.fetch('VAULT_SECRET_ID', ''))
    end
  end
end
