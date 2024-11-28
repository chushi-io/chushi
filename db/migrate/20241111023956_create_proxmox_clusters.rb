class CreateProxmoxClusters < ActiveRecord::Migration[7.1]
  def change
    create_table :proxmox_clusters, id: :uuid do |t|

      t.timestamps
    end
  end
end
