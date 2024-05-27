class CreateRegistryModules < ActiveRecord::Migration[7.1]
  def change
    create_table :registry_modules, id: :uuid do |t|
      t.string :owner
      t.string :namespace
      t.string :name
      t.string :provider

      t.string :source

      t.timestamps

      t.index [:namespace, :name, :provider], unique: true
    end
  end
end
