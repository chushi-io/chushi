class CreateOauthClients < ActiveRecord::Migration[7.1]
  def change
    create_table :oauth_clients, id: :uuid do |t|
      t.string :external_id, index: { unique: true }

      t.string :connect_path
      t.string :service_provider
      t.string :service_provider_display_name
      t.string :name

      t.string :auth_identifier, index: { unique: true }
      t.string :http_url
      t.string :api_url

      # Client information
      t.string :key
      t.string :secret_encrypted

      # SSH Key information
      t.string :rsa_public_key
      t.string :private_key_encrypted

      # Access Token
      t.string :oauth_token_string_encrypted
      t.boolean :organization_scoped
      t.references :organization, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
