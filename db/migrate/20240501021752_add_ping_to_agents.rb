# frozen_string_literal: true

class AddPingToAgents < ActiveRecord::Migration[7.1]
  def change
    add_column :agents, :last_ping_at, :timestamp
    add_column :agents, :ip_address, :string
  end
end
