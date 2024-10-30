class AddConfigurationVersionToWorkspace < ActiveRecord::Migration[7.1]
  def change
    add_reference :workspaces, :current_configuration_version, foreign_key: { to_table: :configuration_versions }, index: true,
                  type: :uuid
  end
end
