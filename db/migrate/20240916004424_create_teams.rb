class CreateTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :teams, id: :uuid do |t|
      t.string :external_id, index: { unique: true }

      t.string :name
      t.string :sso_team_id
      t.integer :users_count
      t.string :visibility
      t.boolean :allow_member_token_management

      t.references :organization, foreign_key: true, type: :uuid
      t.index %i[organization_id name], unique: true

      t.timestamps
    end
  end
end
