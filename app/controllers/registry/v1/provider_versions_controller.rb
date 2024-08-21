class Registry::V1::ProviderVersionsController < Registry::RegistryController
  before_action :load_provider

  def index
    @versions = @provider.provider_versions
    render json: ::ProviderVersionSerializer.new(@versions, {}).serializable_hash
  end

  def show

  end

  def create
    @version = @provider.provider_versions.new(version_params)
  end

  def destroy

  end

  private
  def load_provider
    @provider = @current_organization.providers.find(params[:id])
  end

  def version_params

  end
end
