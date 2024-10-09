CarrierWave.configure do |config|
  config.fog_credentials = {
    provider:              Chushi.storage.provider.upcase
  }
  config.fog_public     = false
end