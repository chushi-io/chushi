# frozen_string_literal: true

class NotificationConfigurationSerializer < ApplicationSerializer
  set_type 'notification-configurations'

  attribute :enabled
  attribute :name
  attribute :url
  attribute :destination_type
  attribute :token
  attribute :triggers
  attribute :delivery_responses do |object|
    object.notification_delivery_responses.each do |res|
      {
        url: res.url,
        body: res.body,
        code: res.code,
        headers: res.headers,
        'sent-at': res.sent_at,
        successful: res.successful
      }
    end
  end

  belongs_to :subscribable, serializer: WorkspaceSerializer, id_method_name: :external_id, &:workspace
end
