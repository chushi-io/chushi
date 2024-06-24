class Api::V1::WebhooksController < Api::ApiController
  skip_before_action :verify_access_token

  def create
    puts request.body
  end
end
