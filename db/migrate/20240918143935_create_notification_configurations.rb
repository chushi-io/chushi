# frozen_string_literal: true

class CreateNotificationConfigurations < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_configurations, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.references :workspace, foreign_key: true, type: :uuid
      t.string :destination_type
      t.boolean :enabled
      t.string :name
      t.string :token
      t.text :triggers, array: true, default: []
      t.string :url

      t.index %i[workspace_id name], unique: true
      t.index %i[workspace_id url], unique: true

      t.timestamps
    end
  end
end
