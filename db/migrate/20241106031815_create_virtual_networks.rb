class CreateVirtualNetworks < ActiveRecord::Migration[7.1]
  def change
    create_table :virtual_networks, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.references :organization, foreign_key: true, type: :uuid

      t.string :name
      t.string :cloud
      t.string :region
      t.string :cidr_block

      t.belongs_to :network_attachable, polymorphic: true, type: :uuid

      t.timestamps
    end
  end
end
