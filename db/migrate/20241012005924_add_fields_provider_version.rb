class AddFieldsProviderVersion < ActiveRecord::Migration[7.1]
  def change
    remove_column :provider_versions, :platforms, :json
    remove_column :provider_versions, :gpg_public_keys, :json
    remove_column :provider_versions, :published_at, :timestamp
    remove_column :provider_versions, :archive, :text

    add_column :provider_versions, :key_id, :string
    add_column :provider_versions, :shasums_uploaded, :boolean
    add_column :provider_versions, :shasums_sig_uploaded, :boolean
    add_column :provider_versions, :external_id, :string
    add_index :provider_versions, :external_id, unique: true
  end
end
