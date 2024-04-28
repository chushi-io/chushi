class AddUniqueNameIndexForWorkspaces < ActiveRecord::Migration[7.1]
  def change
    add_index(:workspaces, [:organization_id, :name], unique: true)
  end
end
