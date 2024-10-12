class Api::V2::RegistryProvidersController < Api::ApiController
  def index
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :show?
    @providers = @org.providers

    render json: ::ProviderSerializer.new(@providers, {}).serializable_hash
  end

  def create
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :manage_modules?

    @provider = @org.providers.new(provider_params)
    @provider.namespace = @org.name
    @provider.registry = 'private'
    @provider.save
    render json: ::ProviderSerializer.new(@provider, {}).serializable_hash
  end

  def show
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :show?
    @provider = @org.providers.where(
      namespace: params[:namespace],
      name: params[:name]
    ).first

    render json: ::ProviderSerializer.new(@provider, {}).serializable_hash
  end

  def destroy

  end

  private
  def provider_params
    map_params([:name])
  end
end
