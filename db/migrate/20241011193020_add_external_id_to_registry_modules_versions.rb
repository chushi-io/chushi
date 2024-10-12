class AddExternalIdToRegistryModulesVersions < ActiveRecord::Migration[7.1]
  def change
    add_column :registry_module_versions, :external_id, :string
    add_index :registry_module_versions, :external_id, :unique => true
  end
end
