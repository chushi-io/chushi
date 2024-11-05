class CreateOauthTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :oauth_tokens, id: :uuid do |t|
      t.string :external_id, index: { unique: true }

      t.string :service_provider_user
      t.boolean :has_ssh_key

      t.references :oauth_client, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
