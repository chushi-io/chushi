# frozen_string_literal: true

class CreateStateVersionOutputs < ActiveRecord::Migration[7.1]
  def change
    create_table :state_version_outputs, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.string :name
      t.boolean :sensitive
      t.string :output_type
      t.text :value

      t.references :state_version, foreign_key: true, type: :uuid
      t.references :organization, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
