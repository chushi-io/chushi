class AddLogsToApplies < ActiveRecord::Migration[7.1]
  def change
    add_column :applies, :logs, :text
  end
end
