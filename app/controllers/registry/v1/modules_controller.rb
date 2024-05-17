class Registry::V1::ModulesController < Registry::RegistryController
  include ActiveStorage::SetCurrent
  def index
    @modules = RegistryModule.where(params.permit(
      :namespace,
      :name,
      :provider
    ))
    render json: @modules
  end

  def search
    unless params[:q]
      head :bad_request
    end

    @modules = RegistryModule.where()
    render json: @modules
  end

  def versions
    @modules = RegistryModule.where(
      namespace: params[:namespace],
      name: params[:name],
      provider: params[:provider]
    )
    render json: @modules
  end

  def download
    if params[:version]
      # Redirect to the archive path
      registry_module = RegistryModule.where(
        namespace: params[:namespace],
        name: params[:name],
        provider: params[:provider],
        version: params[:version]
      ).first
    else
      # Download latest
      registry_module = RegistryModule.where(
        namespace: params[:namespace],
        name: params[:name],
        provider: params[:provider]
      ).order(version: :desc).first
    end

    if registry_module
      response.headers['X-Terraform-Get'] = registry_module.archive.url
      head :no_content
    else
      head :not_found
    end
  end

  def archive
    @module = RegistryModule.where(
      namespace: params[:namespace],
      name: params[:name],
      provider: params[:provider],
      version: params[:version]
    ).first
    @module.increment!(:downloads)

    # Get the archive and download it
  end

  def latest
    @modules = RegistryModule.where(
      namespace: params[:namespace],
      name: params[:name]
    )
    # TODO: Grab all of the latest stuffs
    render json: @modules
  end

  def show

  end

  def create
    @module = RegistryModule.new(
      name: params[:name],
      namespace: params[:namespace],
      provider: params[:provider],
      version: params[:version]
    )
    @module.published_at = Time.now
    @module.save!
    request.body.rewind
    @module.archive.attach(io: request.body, filename: "#{params[:namespace]}-#{params[:name]}-#{params[:provider]}-#{params[:version]}.tar.gz")
    render json: @module
  end

  private
  def module_params
    params.permit(:namespace, :name, :provider, :version)
  end
end
