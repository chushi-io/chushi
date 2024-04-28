class AddAgentIdToObjects < ActiveRecord::Migration[7.1]
  def change
    change_table :workspaces do |t|
      t.references :agent, foreign_key: true, type: :uuid
    end

    change_table :organizations do |t|
      t.references :agent, foreign_key: true, type: :uuid
    end
  end
end
