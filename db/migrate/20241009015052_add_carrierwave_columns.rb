# frozen_string_literal: true

class AddCarrierwaveColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :configuration_versions, :archive, :string
    add_column :registry_module_versions, :archive, :string
    add_column :plans, :plan_file, :string
    add_column :plans, :plan_json_file, :string
    add_column :plans, :plan_structured_file, :string
    add_column :provider_versions, :archive, :string
    add_column :state_versions, :state_file, :string
    add_column :state_versions, :state_json_file, :string
  end
end
