class Api::V1::WebhooksController < Api::ApiController
  skip_before_action :verify_access_token
  skip_verify_authorized only: :create

  def create
    puts request.body
  end
end
