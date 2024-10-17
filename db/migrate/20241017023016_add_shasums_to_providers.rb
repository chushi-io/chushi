class AddShasumsToProviders < ActiveRecord::Migration[7.1]
  def change
    add_column :provider_versions, :shasums, :text
    add_column :provider_versions, :shasums_sig, :text
  end
end
