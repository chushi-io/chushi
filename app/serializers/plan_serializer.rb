# frozen_string_literal: true

class PlanSerializer < ApplicationSerializer
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
    encrypt_storage_url({ id: object.id, class: object.class.name, filename: 'logs' })
  end
end
