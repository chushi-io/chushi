class CreateProviderVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :provider_versions, id: :uuid do |t|
      t.string :version
      t.json :protocols
      t.json :platforms
      t.json :gpg_public_keys
      t.timestamp :published_at

      t.references :provider, foreign_key: true, type: :uuid

      t.index %i[provider_id version], unique: true
      t.timestamps
    end
  end
end
