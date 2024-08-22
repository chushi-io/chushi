class CreateWorkspaces < ActiveRecord::Migration[7.1]
  def change
    create_table :workspaces, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.boolean :allow_destroy_plan
      t.boolean :auto_apply

      t.boolean :auto_apply_run_trigger
      t.timestamp :auto_destroy_at

      t.string :description
      t.string :environment
      t.string :execution_mode
      t.boolean :file_triggers_enabled
      t.boolean :global_remote_state
      t.timestamp :latest_change_at
      t.boolean :locked
      t.string :name
      t.boolean :operations

      t.boolean :policy_check_failures
      t.integer :resource_count
      t.integer :run_failures
      t.string :source
      t.boolean :speculative_enabled
      t.boolean :structured_run_output_enabled
      t.string :tofu_version
      t.json :trigger_prefixes
      t.string :vcs_repo
      t.string :vcs_repo_identifier
      t.string :working_directory

      t.timestamps

      t.references :vcs_connection, foreign_key: true, type: :uuid
      t.references :organization, foreign_key: true, type: :uuid

    end
  end
end
