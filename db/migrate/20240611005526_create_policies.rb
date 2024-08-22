class CreatePolicies < ActiveRecord::Migration[7.1]
  def change
    create_table :policies, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.string :name
      t.string :description
      t.string :type
      t.string :query
      t.string :enforcement_level

      t.references :organization, foreign_key: true, type: :uuid
      t.references :policy_set, foreign_key: true, type: :uuid

      t.index [:organization_id, :name], unique: true

      t.timestamps
    end
  end
end
