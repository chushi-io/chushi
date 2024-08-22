class CreateVariables < ActiveRecord::Migration[7.1]
  def change
    create_table :variables, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.string :variable_type

      t.string :name
      t.string :value
      t.string :description
      t.boolean :sensitive

      t.references :organization, foreign_key: true, type: :uuid
      t.references :workspace, foreign_key: true, type: :uuid
      t.references :variable_set, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
