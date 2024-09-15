class PlanSerializer < ApplicationSerializer
  singleton_class.include Rails.application.routes.url_helpers

  set_type :plans

  attribute :execution_details do |object|
    {
      mode: object.execution_mode
    }
  end

  attribute :has_changes
  attribute :resource_additions
  attribute :resource_changes
  attribute :resource_destructions
  attribute :resource_imports
  attribute :status
  attribute :log_read_url do |object|
    logs_api_v2_plan_url(object, host: 'caring-foxhound-whole.ngrok-free.app', protocol: 'https')
  end

end
