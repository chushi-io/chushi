class Api::V1::ConfigurationVersionsController < Api::ApiController
  include ActiveStorage::SetCurrent
  skip_before_action :verify_access_token, :only => [:upload]
  skip_verify_authorized only: :upload

  def create
    @workspace = Workspace.find(external_id: params[:id])
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

  def upload
    @version = ConfigurationVersion.find(external_id: params[:id])

    head :bad_request and return if @version.archive.attached?

    request.body.rewind
    @version.archive.attach(io: request.body, filename: "archive")

    render json: @version.errors.full_messages unless @version.save

    if @version.auto_queue_runs
      # TODO: Trigger a job for queueing the runs after upload
    end

    @version.status = "uploaded"
    @version.save
    render json: @version
  end

  def download
    @version = ConfigurationVersion.find(external_id: params[:id])
    authorize! @version
    # Generate the URL, and return a redirect
    redirect_to @version.archive.url
  end

  def show
    @version = ConfigurationVersion.find(external_id: params[:id])
    authorize! @version
    render json: ::ConfigurationVersionSerializer.new(@version, {}).serializable_hash
  end
end
