class CreateAccessTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :access_tokens, id: :uuid do |t|
      t.string :name
      t.string :description
      t.string :external_id
      t.string :token
      t.references :token_authable, polymorphic: true, null: false, type: :uuid
      t.string :scopes
      t.timestamp :last_used_at
      t.timestamp :expired_at
      t.timestamps

      t.index :token, unique: true
    end
  end
end
