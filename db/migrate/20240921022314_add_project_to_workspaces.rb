# frozen_string_literal: true

class AddProjectToWorkspaces < ActiveRecord::Migration[7.1]
  def change
    add_reference :workspaces, :project, foreign_key: true, type: :uuid, index: true
  end
end
