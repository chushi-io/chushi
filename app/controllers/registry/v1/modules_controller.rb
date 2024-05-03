class Registry::V1::ModulesController < Registry::RegistryController
  def index
    if params[:namespace]

    end
  end

  def search

  end

  def versions

  end

  def download
    if params[:version]
      # Download a specific version
    else
      # Download latests
    end
  end

  def latest
    if params[:provider]
      # Get single provider latest
    else
      # Get latest for all in organization
    end
  end

  def show

  end

  def create

  end
end
