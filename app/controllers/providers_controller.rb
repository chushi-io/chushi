# frozen_string_literal: true

class ProvidersController < AuthenticatedController
  def index
    @providers = @organization.providers
  end

  def show
    @provider = @organization.providers.find_by(external_id: params[:id])
  end
end
