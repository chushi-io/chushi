class WellKnownController < ApplicationController
  def terraform
    render json: {
      "modules.v1": "/api/v1/registry/modules/",
      "providers.v1": "/api/v1/registry/providers/",
      "motd.v1": "/api/tofu/motd",
      "state.v2": "/api/v1/",
      "tfe.v2": "/api/v1/",
      "tfe.v2.1": "/api/v1/",
      "tfe.v2.2": "/api/v1/",
      "versions.v1": "/api/v1/versions/"
    }
  end
end
