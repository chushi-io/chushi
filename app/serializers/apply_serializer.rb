# frozen_string_literal: true

class ApplySerializer < ApplicationSerializer
  set_type :applies

  attribute :execution_details do |object|
    {
      mode: object.execution_mode
    }
  end

  attribute :log_read_url do |object|
    encrypt_upload_url({ id: object.id, class: object.class.name, file: 'logs' })
  end

  attribute :status
  attribute :resource_additions
  attribute :resource_changes
  attribute :resource_destructions
  attribute :resource_imports

  attribute :created_at
  attribute :updated_at
end
