class CreatePlans < ActiveRecord::Migration[7.1]
  def change
    create_table :plans, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
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

# SELECT "runs".* FROM "runs" LEFT OUTER JOIN "workspaces" ON "workspaces"."id" = "runs"."workspace_id" WHERE "workspaces"."agent_id" = $1 AND "runs"."status" IN ($2, $3)  [["agent_id", "0bc5a45a-ccbc-4377-9644-7e00b8bd3213"], ["status", "plan_queued"], ["status", "apply_queued"]]
