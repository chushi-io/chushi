# frozen_string_literal: true

class ApplicationController < ActionController::Base
  add_flash_types :info, :error, :warning

  def index
    render file: "public/app/index.html", layout: false
  end
end
