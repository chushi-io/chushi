class CreateOpenbaoClusters < ActiveRecord::Migration[7.1]
  def change
    create_table :openbao_clusters, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.references :organization, foreign_key: true, type: :uuid
      t.references :project
      t.references :virtual_network, foreign_key: true, type: :uuid

      t.string :name
      t.string :size
      t.string :status
      t.string :version

      t.json :upgrade_strategy
      t.json :metrics

      t.json :allowed_ip_addresses
      t.string :public_endpoint_url
      t.string :private_endpoint_url
      t.string :region

      t.index %i[organization_id name], unique: true
      t.timestamps
    end
  end
end
