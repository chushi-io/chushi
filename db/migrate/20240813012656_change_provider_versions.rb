class ChangeProviderVersions < ActiveRecord::Migration[7.1]
  def change
    remove_column :provider_versions, :platforms, :json
    remove_column :provider_versions, :gpg_public_keys, :json
    add_column :provider_versions, :key_id, :string
  end
end
