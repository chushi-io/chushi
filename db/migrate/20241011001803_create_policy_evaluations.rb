class CreatePolicyEvaluations < ActiveRecord::Migration[7.1]
  def change
    create_table :policy_evaluations, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.string :policy_kind
      t.string :policy_tool_version
      t.json :result_count
      t.json :status_timestamps
      t.string :policy_set_id

      t.references :task_stage, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
