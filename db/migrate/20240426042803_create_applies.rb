class CreateApplies < ActiveRecord::Migration[7.1]
  def change
    create_table :applies, id: :uuid do |t|
      t.string :execution_mode
      t.string :status
      t.string :logs_url
      t.integer :resource_additions
      t.integer :resource_changes
      t.integer :resource_destructions
      t.integer :resource_imports

      t.references :organization, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
