class CreateKubernetesClusters < ActiveRecord::Migration[7.1]
  def change
    create_table :kubernetes_clusters, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.references :organization, foreign_key: true, type: :uuid
      t.references :virtual_network,foreign_key: true, type: :uuid
      t.references :cloud_provider, foreign_key: true, type: :uuid
      t.references :kubernetes_cluster, foreign_key: { to_table: :kubernetes_clusters, type: :uuid }

      t.belongs_to :infrastructure_configuration, polymorphic: true
      t.belongs_to :control_plane_configuration, polymorphic: true

      t.string :cluster_network_pods_cidr_block

      t.string :version
      t.string :status
      # Wether this cluster is managed by Chushi
      t.boolean :managed



      t.string :control_plane_endpoint_host
      t.integer :control_plane_endpoint_port

      # These will only be set in conjunction with
      # the "kubernetes_cluster" self reference above
      t.string :name
      t.string :namespace

      # Capabilities of the managed cluster. These signify
      # the types of processes that can run on, or target,
      # the cluster
      # - tofu
      # - openbao
      # - service
      # - clusterapi
      t.json :capabilities
      t.timestamps
    end
  end
end
