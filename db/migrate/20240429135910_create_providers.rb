# frozen_string_literal: true

class CreateProviders < ActiveRecord::Migration[7.1]
  def change
    create_table :providers, id: :uuid do |t|
      t.string :namespace
      t.string :provider_type

      t.timestamps
      t.index %i[namespace provider_type], unique: true
    end
  end
end
