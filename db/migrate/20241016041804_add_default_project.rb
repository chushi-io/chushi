class AddDefaultProject < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :is_default, :boolean, default: false
  end
end
