class CreateRuns < ActiveRecord::Migration[7.1]
  def change
    create_table :runs, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.references :agent, foreign_key: true, type: :uuid

      t.boolean :has_changes
      t.boolean :auto_apply
      t.boolean :is_destroy
      t.string :message
      t.boolean :plan_only
      t.string :source
      t.string :status
      t.string :trigger_reason
      t.boolean :refresh
      t.boolean :refresh_only
      t.boolean :save_plan

      t.references :configuration_version, foreign_key: true, type: :uuid
      t.references :workspace, foreign_key: true, type: :uuid
      t.references :plan, foreign_key: true, type: :uuid
      t.references :apply, foreign_key: true, type: :uuid
      t.references :organization, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
