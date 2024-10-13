# frozen_string_literal: true

class CreateRegistryModuleVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :registry_module_versions, id: :uuid do |t|
      t.string :version
      t.string :location
      t.string :source

      t.string :definition
      t.json :root
      t.json :submodules

      t.integer :downloads
      t.boolean :verified
      t.timestamp :published_at

      t.references :registry_module, foreign_key: true, type: :uuid

      t.index %i[registry_module_id version], unique: true
      t.timestamps
    end
  end
end
