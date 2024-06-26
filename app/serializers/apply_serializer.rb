class ApplySerializer
  singleton_class.include Rails.application.routes.url_helpers

  include JSONAPI::Serializer

  set_type :applies
  set_key_transform :dash

  attribute :execution_details do |object|
    {
      "mode": object.execution_mode
    }
  end

  attribute :log_read_url do |object|
    logs_api_v1_apply_url(object, host: 'caring-foxhound-whole.ngrok-free.app', protocol: 'https')
  end

  attribute :status
  attribute :resource_additions
  attribute :resource_changes
  attribute :resource_destructions
  attribute :resource_imports

  attribute :created_at
  attribute :updated_at
end
