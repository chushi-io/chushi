class AddRedactedJsonOutput < ActiveRecord::Migration[7.1]
  def change
    add_column :plans, :redacted_json, :text
  end
end
