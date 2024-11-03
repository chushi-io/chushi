class AddCurrentRunToWorkspaces < ActiveRecord::Migration[7.1]
  def change
    add_reference :workspaces, :current_run, foreign_key: { to_table: :runs }, index: true,
                  type: :uuid
  end
end
