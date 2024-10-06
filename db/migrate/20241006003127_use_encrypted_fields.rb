class UseEncryptedFields < ActiveRecord::Migration[7.1]
  def change
    add_column :variables, :value_encrypted, :string
    add_column :notification_configurations, :token_encrypted, :string
    add_column :run_tasks, :hmac_key_encrypted, :string
    add_column :ssh_keys, :private_key_encrypted, :string
    add_column :state_versions, :value_encrypted, :string
    add_column :vcs_connections, :github_personal_access_token_encrypted, :string
    add_column :vcs_connections, :github_application_secret_encrypted, :string
    add_column :vcs_connections, :github_oauth_application_secret_encrypted, :string
    add_column :vcs_connections, :webhook_secret_encrypted, :string
  end
end
