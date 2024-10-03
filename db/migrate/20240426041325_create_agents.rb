class CreateAgents < ActiveRecord::Migration[7.1]
  def change
    create_table :agents, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.references :organization, foreign_key: true, type: :uuid

      t.boolean :organization_scoped, default: false
      t.string :status
      t.string :name

      t.timestamps
    end
    add_index(:agents, [:organization_id, :name], unique: true)
  end
end
