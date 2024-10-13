# frozen_string_literal: true

module Registry
  class RegistryController < ActionController::API
    def encrypt_storage_url(object)
      api_v2_get_storage_url(
        Base64.strict_encode64(
          Vault::Rails.encrypt('transit', 'chushi_storage_url', object.to_json)
        ),
        host: Chushi.domain,
        protocol: 'https'
      )
    end
  end
end
