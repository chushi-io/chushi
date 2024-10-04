class UseAgentPools < ActiveRecord::Migration[7.1]
  def change
    rename_table :agents, :agent_pools
  end
end
