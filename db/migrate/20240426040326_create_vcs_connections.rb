class CreateVcsConnections < ActiveRecord::Migration[7.1]
  def change
    create_table :vcs_connections, id: :uuid  do |t|
      t.string :name
      t.string :provider
      t.string :github_type
      t.string :github_personal_access_token
      t.string :github_application_id
      t.string :github_application_secret
      t.string :github_oauth_application_id
      t.string :github_oauth_application_secret

      t.references :organization, foreign_key: true, type: :uuid
      t.string :webhook_id
      t.string :webhook_secret

      t.timestamps
    end

    add_index(:vcs_connections, [:organization_id, :name])

  end
end
