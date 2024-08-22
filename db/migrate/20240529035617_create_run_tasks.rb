class CreateRunTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :run_tasks, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.string :category
      t.string :name
      t.string :url
      t.string :hmac_key
      t.boolean :enabled
      t.string :description

      t.references :organization, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
