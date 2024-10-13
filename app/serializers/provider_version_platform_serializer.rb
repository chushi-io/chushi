class ProviderVersionPlatformSerializer < ApplicationSerializer
  set_type ""

  attribute :os
  attribute :arch
  attribute :filename
  attribute :shasum
  attribute :permissions do |object| {} end
  attribute :provider_binary_uploaded do |object|
    object.binary.present?
  end

  belongs_to :registry_provider_version, serializer: ProviderVersionSerializer, id_method_name: :name do |object|
    object.provider_version
  end

  link :provider_binary_upload, unless: Proc.new { |record, params|
    record.binary.present?
  } do |object|
    encrypt_upload_url({id: object.id, class: object.class.name})
  end

  link :provider_binary_download, if: Proc.new { |record, params|
    record.binary.present?
  } do |object|
    encrypt_storage_url({id: object.id, class: object.class.name})
  end
end