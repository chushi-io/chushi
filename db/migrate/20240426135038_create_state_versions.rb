class CreateStateVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :state_versions, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.integer :size
      t.string :hosted_state_download_url
      t.string :hosted_state_upload_url
      t.string :hosted_json_state_download_url
      t.string :hosted_json_state_upload_url
      t.string :status
      t.boolean :intermediate
      t.json :modules
      t.json :providers
      t.json :resources
      t.boolean :resources_processed
      t.integer :serial
      t.integer :state_version
      t.string :tofu_version
      t.string :vcs_commit_url
      t.string :vcs_commit_sha

      t.references :workspace, foreign_key: true, type: :uuid
      t.references :run, foreign_key: true, type: :uuid
      t.references :organization, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
