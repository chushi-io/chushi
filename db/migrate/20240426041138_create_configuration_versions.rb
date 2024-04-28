class CreateConfigurationVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :configuration_versions, id: :uuid do |t|
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
