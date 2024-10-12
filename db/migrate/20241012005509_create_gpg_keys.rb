class CreateGpgKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :gpg_keys, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.text :ascii_armor
      t.string :namespace
      t.string :key_id
      t.string :source
      t.string :source_url
      t.string :trust_signature

      t.timestamps
    end
  end
end
