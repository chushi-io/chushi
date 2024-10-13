# frozen_string_literal: true

class AddPolicyFileToPolicy < ActiveRecord::Migration[7.1]
  def change
    add_column :policies, :policy, :string
  end
end
