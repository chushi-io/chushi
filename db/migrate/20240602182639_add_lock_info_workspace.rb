class AddLockInfoWorkspace < ActiveRecord::Migration[7.1]
  def change
    add_column :workspaces, :locked_by, :string
    add_column :workspaces, :locked_at, :timestamp
    add_column :workspaces, :lock_id, :string
  end
end
