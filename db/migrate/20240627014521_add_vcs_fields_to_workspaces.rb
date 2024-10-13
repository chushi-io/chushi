# frozen_string_literal: true

class AddVcsFieldsToWorkspaces < ActiveRecord::Migration[7.1]
  def change
    add_column :workspaces, :vcs_repo_branch, :string
    remove_column :workspaces, :vcs_repo
  end
end
