# frozen_string_literal: true

class CreateWorkspaceTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :workspace_teams, id: :uuid do |t|
      t.string :external_id, index: { unique: true }

      t.references :organization, foreign_key: true, type: :uuid
      t.references :workspace, foreign_key: true, type: :uuid
      t.references :team, foreign_key: true, type: :uuid

      t.string :access, default: :null
      t.string :runs, default: :null
      t.string :variables, default: :null
      t.string :state_versions, default: :null
      t.boolean :workspace_locking, default: false
      t.boolean :run_tasks, default: false

      t.index %i[workspace_id team_id], unique: true

      t.timestamps
    end
  end
end
