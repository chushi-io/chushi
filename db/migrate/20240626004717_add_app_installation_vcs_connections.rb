# frozen_string_literal: true

class AddAppInstallationVcsConnections < ActiveRecord::Migration[7.1]
  def change
    add_column :vcs_connections, :github_installation_id, :integer
  end
end
