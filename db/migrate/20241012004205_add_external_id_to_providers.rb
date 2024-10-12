class AddExternalIdToProviders < ActiveRecord::Migration[7.1]
  def change
    add_column :providers, :external_id, :string
    add_column :providers, :name, :string
    remove_column :providers, :provider_type, :string
    add_column :providers, :registry, :string
    add_index :providers, :external_id, :unique => true

    add_reference :providers, :organization, foreign_key: true, type: :uuid
  end
end
