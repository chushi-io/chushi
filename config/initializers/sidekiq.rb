Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', nil), size: 1, network_timeout: 5,
                   ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', nil), size: 7, network_timeout: 5,
                   ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
end
