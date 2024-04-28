class AddApiKeyToAgents < ActiveRecord::Migration[7.1]
  def change
    add_column :agents, :api_key, :string
    add_column :agents, :api_secret, :string

    add_index :agents, :api_key,                unique: true
  end
end
