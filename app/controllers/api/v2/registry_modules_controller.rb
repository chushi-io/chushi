class Api::V2::RegistryModulesController < Api::ApiController
  def index
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :show?
    @registry_modules = @org.registry_modules

    render json: ::RegistryModuleSerializer.new(@registry_modules, {}).serializable_hash
  end

  def show
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :show?
    @module = @org.registry_modules.where(
      # registry: "private",
      namespace: params[:namespace],
      name: params[:name],
      provider: params[:provider]
    ).first!

    render json: ::RegistryModuleSerializer.new(@module, {}).serializable_hash
  end

  def update
    head :not_implemented
  end

  def create
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :manage_modules?
    @registry_module = @org.registry_modules.new(module_params)
    @registry_module.namespace = @org.name
    @registry_module.status = "pending"
    @registry_module.save!

    render json: ::RegistryModuleSerializer.new(@registry_module, {}).serializable_hash
  end

  def destroy
    if params[:provider]
      # Delete just that provider?
    else
      # Delete for all providers
    end

    head :not_implemented
  end

  private
  def module_params
    map_params([
      :name,
      :provider
    ])
  end
end
