class RunUseAgentPools < ActiveRecord::Migration[7.1]
  def change
    change_table :jobs do |t|
      t.references :agent_pool, foreign_key: true, type: :uuid
    end
  end
end
