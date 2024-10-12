class CreateProviderVersionPlatforms < ActiveRecord::Migration[7.1]
  def change
    create_table :provider_version_platforms, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.string :os
      t.string :arch
      t.string :shasum
      t.string :filename
      t.references :provider_version, foreign_key: true, type: :uuid
      t.text :binary
      t.timestamps
    end
  end
end
