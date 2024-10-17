class AddMissingRunColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :runs, :target_addrs, :json
    add_column :runs, :refresh_addrs, :json
    add_column :runs, :allow_empty_apply, :boolean
    add_column :runs, :allow_config_generation, :boolean

  end
end
