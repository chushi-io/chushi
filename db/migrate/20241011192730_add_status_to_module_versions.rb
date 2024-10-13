# frozen_string_literal: true

class AddStatusToModuleVersions < ActiveRecord::Migration[7.1]
  def change
    add_column :registry_module_versions, :status, :string
  end
end
