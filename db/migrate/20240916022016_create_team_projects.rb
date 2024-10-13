class CreateTeamProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :team_projects, id: :uuid do |t|
      t.references :organization, foreign_key: true, type: :uuid
      t.references :project, foreign_key: true, type: :uuid
      t.references :team, foreign_key: true, type: :uuid
      t.string :external_id, index: { unique: true }

      # Generic access level
      t.string :access, default: 'read'

      # Project specific access controls
      t.string :project_settings, default: :null
      t.string :project_teams, default: :null

      # Workspace access controls
      t.string :workspace_create, default: :null
      t.string :workspace_move, default: :null
      t.string :workspace_locking, default: :null
      t.string :workspace_delete, default: :null
      t.string :workspace_runs, default: :null
      t.string :workspace_variables, default: :null
      t.string :workspace_state_versions, default: :null
      t.string :workspace_run_tasks, default: :null

      t.timestamps
    end
  end
end
