class Api::V1::ConfigurationVersionsController < Api::ApiController
  include ActiveStorage::SetCurrent
  def create
    @workspace = Workspace.find(params[:id])
    render json: {}, status: :forbidden and return unless can_access_workspace(@workspace)

    version = @workspace.configuration_versions.new(
      auto_queue_runs: params[:auto_queue_runs]
    )
    version.organization = @workspace.organization
    if version.save
      render json: version
    else
      render json: version.errors.full_messages, status: :bad_request
    end
  end

  def upload
    version = ConfigurationVersion.find(params[:id])
    render json: {}, status: :forbidden and return unless can_access_version(version)

    version.archive.attach(io: request.body, filename: "archive")

    render json: version.errors.full_messages unless version.save

    if version.auto_queue_runs
      # TODO: Trigger a job for queueing the runs after upload
    end
    render json: version
  end

  def download
    version = ConfigurationVersion.find(params[:id])
    render json: {}, status: :forbidden and return unless can_access_version(version)

    # Generate the URL, and return a redirect
    redirect_to version.archive.url
  end

  private
  def can_access_version(version)
    # TODO: For now, simply verify organization access
    can_access_organization(version.organization.id)
  end
end
