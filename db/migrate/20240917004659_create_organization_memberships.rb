# frozen_string_literal: true

class CreateOrganizationMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :organization_memberships, id: :uuid do |t|
      t.references :organization, foreign_key: true, type: :uuid
      t.references :user, foreign_key: true, type: :uuid
      t.string :email
      t.string :external_id, index: { unique: true }
      t.string :status

      t.index %i[organization_id user_id], unique: true
      t.index %i[organization_id email], unique: true
      t.timestamps
    end
  end
end
