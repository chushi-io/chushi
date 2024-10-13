# frozen_string_literal: true

class CreateRunTriggers < ActiveRecord::Migration[7.1]
  def change
    create_table :run_triggers, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.references :workspace, foreign_key: true, type: :uuid
      t.references :sourceable, foreign_key: { to_table: :workspaces }, type: :uuid
      t.index %i[workspace_id sourceable_id], unique: true

      t.timestamps
    end
  end
end
