# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :jobs, id: :uuid do |t|
      t.references :organization, foreign_key: true, type: :uuid
      t.references :agent, foreign_key: true, type: :uuid
      t.references :workspace, foreign_key: true, type: :uuid
      t.references :run, foreign_key: true, type: :uuid

      t.string :status
      t.boolean :locked
      t.string :locked_by
      t.integer :priority
      t.string :operation

      t.timestamps
    end
  end
end
