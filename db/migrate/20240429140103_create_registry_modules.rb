class CreateRegistryModules < ActiveRecord::Migration[7.1]
  def change
    create_table :registry_modules, id: :uuid do |t|
      t.string :owner
      t.string :namespace
      t.string :name
      t.string :provider
      t.string :version
      t.string :location
      t.string :definition
      t.json :root
      t.json :submodules
      t.string :source
      t.integer :downloads
      t.boolean :verified
      t.timestamp :published_at

      t.timestamps

      t.index [:namespace, :name, :provider, :version], unique: true
    end
  end
end
