class CreateRegistryModules < ActiveRecord::Migration[7.1]
  def change
    create_table :registry_modules do |t|
      t.string :registry_id
      t.string :owner
      t.string :namespace
      t.string :name
      t.string :provider
      t.string :description
      t.string :location
      t.string :definition
      t.json :root
      t.json :submodules
      t.string :source
      t.integer :downloads
      t.boolean :verified
      t.timestamp :published_at

      t.string :version
      t.timestamps

      t.index :registry_id, unique: true
      t.index [:namespace, :name, :provider, :version], unique: true
    end
  end
end
