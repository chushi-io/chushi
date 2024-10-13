# frozen_string_literal: true

class CreateNewAgents < ActiveRecord::Migration[7.1]
  def change
    create_table :agents, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.references :agent_pool, foreign_key: true, type: :uuid

      t.string :status
      t.string :name
      t.string :ip_address
      t.timestamp :last_ping_at

      t.timestamps
    end
  end
end
