# frozen_string_literal: true

CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', ''),
    aws_secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', ''),
    use_iam_profile: false
  }
  config.fog_public = false

  config.enable_processing = false if Rails.env.test?
end
