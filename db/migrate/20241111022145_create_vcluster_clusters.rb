class CreateVclusterClusters < ActiveRecord::Migration[7.1]
  def change
    create_table :vcluster_clusters, id: :uuid do |t|
      t.string :external_id, index: { unique: true }

      t.string :chart
      t.string :name
      t.string :repo
      t.string :version
      t.text :values

      t.timestamps
    end
  end
end
