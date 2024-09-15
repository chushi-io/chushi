class ApplicationSerializer
  include JSONAPI::Serializer

  set_key_transform :dash
  set_id { |object| object.external_id }   # <- encoded id!
end
