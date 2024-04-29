class Api::V1::PingController < Api::ApiController
  skip_before_action :verify_access_token

  def ping
    response.headers["tfp-api-version"] = "2.6"
    response.headers["tfp-appname"] = "Chushi"
  end
end
