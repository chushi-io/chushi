class AddLogsToPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :plans, :logs, :text
  end
end
