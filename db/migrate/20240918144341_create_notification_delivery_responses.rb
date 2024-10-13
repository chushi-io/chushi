# frozen_string_literal: true

class CreateNotificationDeliveryResponses < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_delivery_responses, id: :uuid do |t|
      t.references :notification_configuration, foreign_key: true, type: :uuid
      t.string :url
      t.text :body
      t.string :code
      t.json :headers

      t.timestamp :sent_at
      t.boolean :successful
      t.timestamps
    end
  end
end
