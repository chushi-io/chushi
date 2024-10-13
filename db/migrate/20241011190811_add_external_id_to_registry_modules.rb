class AddExternalIdToRegistryModules < ActiveRecord::Migration[7.1]
  def change
    add_column :registry_modules, :external_id, :string
    add_index :registry_modules, :external_id, unique: true

    add_column :registry_modules, :status, :string
    add_reference :registry_modules, :organization, foreign_key: true, type: :uuid
  end
end
