class EncryptAccessTokens < ActiveRecord::Migration[7.1]
  def change
    add_column :access_tokens, :token_encrypted, :string
  end
end
