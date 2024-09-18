class CreateSshKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :ssh_keys, id: :uuid do |t|
      t.string :external_id, index: { unique: true }

      t.references :organization, foreign_key: true, type: :uuid
      t.string :name
      t.text :private_key
      t.timestamps

      t.index [:organization_id, :name], unique: true

    end
  end
end
