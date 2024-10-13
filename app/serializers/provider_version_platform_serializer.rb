# frozen_string_literal: true

class ProviderVersionPlatformSerializer < ApplicationSerializer
  set_type ''

  attribute :os
  attribute :arch
  attribute :filename
  attribute :shasum
  attribute :permissions do |_object|
    {}
  end
  attribute :provider_binary_uploaded do |object|
    object.binary.present?
  end

  belongs_to :registry_provider_version, serializer: ProviderVersionSerializer, id_method_name: :name,
             &:provider_version

  link :provider_binary_upload, unless: proc { |record, _params|
    record.binary.present?
  } do |object|
    encrypt_upload_url({ id: object.id, class: object.class.name })
  end

  link :provider_binary_download, if: proc { |record, _params|
    record.binary.present?
  } do |object|
    encrypt_storage_url({ id: object.id, class: object.class.name })
  end
end
