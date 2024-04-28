class CreateWorkspaceResources < ActiveRecord::Migration[7.1]
  def change
    create_table :workspace_resources, id: :uuid do |t|
      t.string :address
      t.string :name
      t.string :module
      t.string :provider
      t.string :provider_type
      t.references :state_version, foreign_key: true, type: :uuid
      t.references :organization, foreign_key: true, type: :uuid
      t.string :name_index
      t.timestamps
    end
  end
end
