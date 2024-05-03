class CreateProviders < ActiveRecord::Migration[7.1]
  def change
    create_table :providers do |t|
      t.string :namespace
      t.string :provider_type
      t.string :version
      t.json :protocols
      t.json :platforms
      t.json :gpg_public_keys
      t.timestamps
    end
  end
end
