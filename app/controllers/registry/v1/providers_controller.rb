class Registry::V1::ProvidersController < Registry::RegistryController
  def index

  end

  def create
    @provider = Provider.new(
      namespace: params[:namespace],
      provider_type: params[:type],
      version: params[:version]
    )
    @provider.published_at = Time.now
    @provider.save!
    request.body.rewind
    @provider.archive.attach(io: request.body, filename: "#{params[:namespace]}-#{params[:name]}-#{params[:provider]}-#{params[:version]}.tar.gz")
    render json: @provider
  end
end
