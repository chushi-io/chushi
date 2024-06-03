class ChangePlanColumnsToInt < ActiveRecord::Migration[7.1]
  def change
    change_column :plans, :resource_additions, :integer, :using => '0'
    change_column :plans, :resource_changes, :integer, :using => '0'
    change_column :plans, :resource_destructions, :integer, :using => '0'
    change_column :plans, :resource_imports, :integer, :using => '0'
  end
end
