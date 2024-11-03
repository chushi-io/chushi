# frozen_string_literal: true

class EncryptedStorage
  singleton_class.include Rails.application.routes.url_helpers

  def self.storage_url(object)
    object[:method] = 'get'
    token = Vault::Rails.encrypt('transit', 'chushi_storage_url', object.to_json)
    enc = Base64.strict_encode64(token)
    api_v2_get_storage_url(enc, host: Chushi.domain, protocol: 'https')
  end

  def self.upload_url(object)
    object[:method] = 'put'
    token = Vault::Rails.encrypt('transit', 'chushi_storage_url', object.to_json)
    enc = Base64.strict_encode64(token)
    api_v2_upload_storage_url(enc, host: Chushi.domain, protocol: 'https')
  end

  def self.decrypt(contents)
    if contents.start_with?('vault:')
      Vault::Rails.decrypt('transit', 'chushi_storage_contents', contents)
    else
      contents
    end
  end

  def self.encrypt(contents)
    Vault::Rails.encrypt('transit', 'chushi_storage_contents', contents)
  end
end
