# frozen_string_literal: true

class CreateTeamMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :team_memberships, id: :uuid do |t|
      t.references :organization, foreign_key: true, type: :uuid
      t.references :team, foreign_key: true, type: :uuid
      t.references :user, foreign_key: true, type: :uuid
      t.string :external_id, index: { unique: true }

      t.index %i[team_id user_id], unique: true
      t.timestamps
    end
  end
end
