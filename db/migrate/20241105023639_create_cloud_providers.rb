class CreateCloudProviders < ActiveRecord::Migration[7.1]
  def change
    create_table :cloud_providers, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.references :organization, foreign_key: true, type: :uuid

      t.string :cloud
      t.string :name
      t.string :display_name

      # AWS Credentials
      t.string :aws_account_id
      t.string :aws_access_key_id
      t.string :aws_secret_access_key_encrypted
      t.string :aws_iam_role

      # GCP Credentials
      t.string :gcp_project
      t.string :gcp_service_account_json_encrypted
      t.string :gcp_workload_identity_provider
      t.string :gcp_service_account_email

      t.timestamps
    end
  end
end
