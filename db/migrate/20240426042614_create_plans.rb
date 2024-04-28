class CreatePlans < ActiveRecord::Migration[7.1]
  def change
    create_table :plans, id: :uuid do |t|
      t.string :execution_mode
      t.boolean :has_changes
      t.boolean :resource_additions
      t.boolean :resource_changes
      t.boolean :resource_destructions
      t.boolean :resource_imports
      t.string :status
      t.string :logs_url

      t.references :organization, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
