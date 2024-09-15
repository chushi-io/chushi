class Api::V2::PingController < ActionController::API
  # skip_before_action :verify_access_token

  def ping
    response.set_header('tfp-api-version', '2.6')
    # Ideally we'd set this to Chushi, but the opentofu binary
    # is still hardcoded to "Terraform Cloud" and we want to configure
    # as Cloud, not Enterprise
    response.set_header('tfp-appname', 'Terraform Cloud')
  end
end
