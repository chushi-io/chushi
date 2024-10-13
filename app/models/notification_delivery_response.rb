# frozen_string_literal: true

class NotificationDeliveryResponse < ApplicationRecord
  belongs_to :notification_configuration
end
