class WellKnownController < ApplicationController
  def terraform
    render json: {
      "modules.v1": '/registry/v1/modules',
      "providers.v1": '/registry/v1/providers',
      "motd.v1": '/api/tofu/motd',
      "state.v2": '/api/v2/',
      "tfe.v2": '/api/v2/',
      "tfe.v2.1": '/api/v2/',
      "tfe.v2.2": '/api/v2/',
      "versions.v1": '/api/v1/versions/'
    }
  end
end
