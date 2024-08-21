class ProviderSerializer
  include JSONAPI::Serializer
  set_key_transform :dash

  set_type :providers

  attribute :namespace
  attribute :type do |o| o.provider_type end
end
