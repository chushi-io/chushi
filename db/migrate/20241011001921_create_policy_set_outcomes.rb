# frozen_string_literal: true

class CreatePolicySetOutcomes < ActiveRecord::Migration[7.1]
  def change
    create_table :policy_set_outcomes, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.json :outcomes
      t.string :error
      t.boolean :overrideable
      t.string :policy_set_name
      t.string :policy_set_description
      t.json :result_count
      t.string :policy_tool_version

      t.references :policy_evaluation, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
