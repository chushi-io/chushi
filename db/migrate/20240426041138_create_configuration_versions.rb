# frozen_string_literal: true

class CreateConfigurationVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :configuration_versions, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.references :workspace, foreign_key: true, type: :uuid
      t.references :organization, foreign_key: true, type: :uuid

      t.string :source
      t.boolean :speculative
      t.string :status
      t.string :upload_url
      t.boolean :provisional

      t.timestamps
    end
  end
end
