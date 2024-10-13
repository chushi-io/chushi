# frozen_string_literal: true

class AddAutoQueueRunsToConfigVersion < ActiveRecord::Migration[7.1]
  def change
    add_column :configuration_versions, :auto_queue_runs, :boolean, default: false
  end
end
