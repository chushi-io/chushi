class ApplySerializer < ApplicationSerializer
  singleton_class.include Rails.application.routes.url_helpers

  set_type :applies

  attribute :execution_details do |object|
    {
      "mode": object.execution_mode
    }
  end

  attribute :log_read_url do |object|
    logs_api_v1_apply_url(object, host: Chushi.domain, protocol: 'https')
  end

  attribute :status
  attribute :resource_additions
  attribute :resource_changes
  attribute :resource_destructions
  attribute :resource_imports

  attribute :created_at
  attribute :updated_at
end
