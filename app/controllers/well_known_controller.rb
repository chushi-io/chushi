# frozen_string_literal: true

class WellKnownController < ApplicationController
  def terraform
    render json: {
      'modules.v1': '/registry/v1/modules',
      'providers.v1': '/registry/v1/providers',
      'motd.v1': '/api/tofu/motd',
      'state.v2': '/api/v2/',
      'tfe.v2': '/api/v2/',
      'tfe.v2.1': '/api/v2/',
      'tfe.v2.2': '/api/v2/',
      'versions.v1': '/api/v1/versions/'
    }
  end

  def app
    render json: {
      client: Doorkeeper::Application.find_by(name: "Chushi Frontend").uid,
      authority: "https://#{Chushi.domain}"
    }
  end
end
