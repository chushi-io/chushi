class CreateOrganizationUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :organization_users do |t|
      t.references :organization, foreign_key: true, type: :uuid
      t.references :user, foreign_key: true, type: :uuid
      t.string :role
      t.timestamps
    end
  end
end
