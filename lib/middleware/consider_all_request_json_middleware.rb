# frozen_string_literal: true

class Middleware::ConsiderAllRequestJsonMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    env['CONTENT_TYPE'] = 'application/json' if env['PATH_INFO'].match(%r{\A/api/.*}) && env['CONTENT_TYPE'] == ('application/x-www-form-urlencoded') # if match /api/*
    @app.call(env)
  end
end
