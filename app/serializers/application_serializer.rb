class ApplicationSerializer
  singleton_class.include Rails.application.routes.url_helpers
  include JSONAPI::Serializer

  set_key_transform :dash
  set_id { |object| object.external_id }   # <- encoded id!

  def self.encrypt_storage_url(object)
    object[:method] = "get"
    token = Vault::Rails.encrypt("transit", "chushi_storage_url", object.to_json)
    enc = Base64.encode64(token)
    api_v2_get_storage_url(enc, host: Chushi.domain, protocol: 'https')
  end

  def self.encrypt_upload_url(object)
    object[:method] = "upload"
    token = Vault::Rails.encrypt("transit", "chushi_storage_url", object.to_json)
    enc = Base64.encode64(token)
    api_v2_upload_storage_url(enc, host: Chushi.domain, protocol: 'https')
  end
end
