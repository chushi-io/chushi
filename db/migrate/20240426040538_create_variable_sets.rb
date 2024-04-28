class CreateVariableSets < ActiveRecord::Migration[7.1]
  def change
    create_table :variable_sets, id: :uuid do |t|
      t.references :organization, foreign_key: true, type: :uuid

      t.string :name
      t.string :description
      t.boolean :auto_attach
      t.integer :priority
      t.timestamps
    end
  end
end
