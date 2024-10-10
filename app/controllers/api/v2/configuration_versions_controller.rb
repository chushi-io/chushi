class Api::V2::ConfigurationVersionsController < Api::ApiController
  include ActiveStorage::SetCurrent

  def create
    @workspace = Workspace.find_by(external_id: params[:id])
    authorize! @workspace, to: :create_configuration_version?

    version = @workspace.configuration_versions.new(
      auto_queue_runs: params[:auto_queue_runs],
      status: "pending"
    )
    version.organization = @workspace.organization
    if version.save
      render json: ::ConfigurationVersionSerializer.new(version, {}).serializable_hash
    else
      render json: version.errors.full_messages, status: :bad_request
    end
  end

  def download
    @version = ConfigurationVersion.find_by(external_id: params[:id])
    authorize! @version
    redirect_to @version.archive.url, allow_other_host: true
  end

  def show
    @version = ConfigurationVersion.find_by(external_id: params[:id])
    authorize! @version
    render json: ::ConfigurationVersionSerializer.new(@version, {}).serializable_hash
  end
end
