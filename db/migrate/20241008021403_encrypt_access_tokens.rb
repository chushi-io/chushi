# frozen_string_literal: true

class EncryptAccessTokens < ActiveRecord::Migration[7.1]
  def change
    add_column :access_tokens, :token_encrypted, :string
    remove_column :access_tokens, :token
  end
end
