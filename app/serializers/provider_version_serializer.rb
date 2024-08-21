class ProviderVersionSerializer
  include JSONAPI::Serializer
  set_key_transform :dash

  set_type :provider_versions

  attribute :version
  attribute :protocols
  attribute :key_id
end
