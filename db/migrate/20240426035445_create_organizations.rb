class CreateOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name, index: { unique: true }, null: false
      t.boolean :allow_auto_create_workspace, default: false
      t.string :organization_type, null: false
      t.timestamps
      t.string :external_id, index: { unique: true }
    end
  end
end
