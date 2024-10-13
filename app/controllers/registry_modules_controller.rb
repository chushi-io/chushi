class RegistryModulesController < AuthenticatedController
  def index
    @modules = @organization.registry_modules
  end

  def show
    @module = @organization.registry_modules.find_by(external_id: params[:id])
  end

  def new; end

  def create; end

  def edit; end

  def update; end

  def destroy; end
end
