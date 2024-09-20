class CreateTaskResults < ActiveRecord::Migration[7.1]
  def change
    create_table :task_results, id: :uuid do |t|
      t.string :external_id, index: { unique: true }

      t.references :task_stage, foreign_key: true, type: :uuid
      t.references :workspace_task, foreign_key: true, type: :uuid
      t.references :run_task, foreign_key: true, type: :uuid

      t.string :message
      t.string :status
      t.json :status_timestamps
      t.string :url
      t.string :stage
      t.boolean :is_speculative
      t.timestamps
    end
  end
end
