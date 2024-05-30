class AddStateVersionToWorkspaces < ActiveRecord::Migration[7.1]
  def change
    add_reference :workspaces, :current_state_version, foreign_key: { to_table: :state_versions }, index: true, type: :uuid
  end
end
