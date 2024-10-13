# frozen_string_literal: true

class CreateWorkspaceTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :workspace_tasks, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.references :workspace, foreign_key: true, type: :uuid
      t.references :run_task, foreign_key: true, type: :uuid
      t.string :stage
      t.text :stages, default: [], array: true
      t.string :enforcement_level

      t.index %i[workspace_id run_task_id], unique: true

      t.timestamps
    end
  end
end
