class RunTaskSerializer
  include JSONAPI::Serializer
  set_key_transform :dash

  set_type :tasks
  set_id :external_id

  attribute :category
  attribute :name
  attribute :url
  attribute :description
  attribute :enabled
  attribute :hmac_key
end
