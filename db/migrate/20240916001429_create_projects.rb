# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :projects, id: :uuid do |t|
      t.string :external_id, index: { unique: true }

      t.string :name
      t.string :description
      t.integer :team_count
      t.integer :workspace_count
      t.string :auto_destroy_activity_duration

      t.references :organization, foreign_key: true, type: :uuid
      t.index %i[organization_id name], unique: true

      t.timestamps
    end
  end
end
