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
end
