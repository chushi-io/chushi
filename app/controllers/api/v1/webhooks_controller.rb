class Api::V1::WebhooksController < ApplicationController

  def create
    puts request.body
  end
end
