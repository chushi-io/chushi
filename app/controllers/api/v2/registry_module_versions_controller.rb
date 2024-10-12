class Api::V2::RegistryModuleVersionsController < Api::ApiController
  def create
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :manage_modules?
    @module = @org.registry_modules.where(
      # registry: "private",
      namespace: params[:namespace],
      name: params[:name],
      provider: params[:provider]
    ).first!

    @version = @module.registry_module_versions.new(version_params)
    @version.status = "pending"
    @version.source = "tfe-api"
    @version.save

    render json: ::RegistryModuleVersionSerializer.new(@version, {}).serializable_hash
  end

  def destroy
    # Find the version, and delete it
    head :not_implemented
  end

  private
  def version_params
    map_params([:version, :commit_sha])
  end
end
