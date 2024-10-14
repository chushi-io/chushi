# frozen_string_literal: true

class ConsiderAllRequestJsonMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO'].match(/\A\/api\/.*/) # if match /api/*
      if env["CONTENT_TYPE"] == 'application/x-www-form-urlencoded'
        env["CONTENT_TYPE"] = 'application/json'
      end
    end
    @app.call(env)
  end
end
