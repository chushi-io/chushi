class CreateAgents < ActiveRecord::Migration[7.1]
  def change
    create_table :agents, id: :uuid do |t|
      t.references :organization, foreign_key: true, type: :uuid

      t.string :status
      t.string :name

      t.timestamps
    end
    add_index(:agents, [:organization_id, :name], unique: true)
  end
end
