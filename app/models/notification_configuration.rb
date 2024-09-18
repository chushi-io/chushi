class NotificationConfiguration < ApplicationRecord
  has_many :notification_delivery_responses

  belongs_to :workspace
  before_create -> { generate_id("nc") }
end
