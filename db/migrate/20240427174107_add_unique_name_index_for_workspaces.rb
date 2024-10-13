# frozen_string_literal: true

class AddUniqueNameIndexForWorkspaces < ActiveRecord::Migration[7.1]
  def change
    add_index(:workspaces, %i[organization_id name], unique: true)
  end
end
