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

  # This URL should be treated as a secret
  attribute :log_read_url do |object|
    "#{Chushi.timber_url}/files/#{object.run.external_id}_plan.log"
  end

end
