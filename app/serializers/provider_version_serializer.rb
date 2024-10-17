# frozen_string_literal: true

class ProviderVersionSerializer < ApplicationSerializer
  set_type 'registry-provider-versions'

  attribute :version
  attribute :created_at
  attribute :updated_at
  attribute :key_id
  attribute :protocols
  attribute :permissions do |_object|
    {}
  end
  attribute :shasums_uploaded
  attribute :shasums_sig_uploaded

  attribute :shasums_upload, unless: proc { |record, _params|
    record.shasums.present?
  } do |object|
    encrypt_upload_url({ id: object.id, class: object.class.name, file: "shasums" })
  end

  attribute :shasums_sig_upload, unless: proc { |record, _params|
    record.shasums_sig.present?
  } do |object|
    encrypt_upload_url({ id: object.id, class: object.class.name, file: "shasums.sig" })
  end

  attribute :shasums_download, if: proc { |record, _params|
    record.shasums.present?
  } do |object|
    encrypt_storage_url({ id: object.id, class: object.class.name, file: "shasums" })
  end

  attribute :shasums_sig_download, if: proc { |record, _params|
    record.shasums_sig.present?
  } do |object|
    encrypt_storage_url({ id: object.id, class: object.class.name, file: "shasums.sig" })
  end
end
