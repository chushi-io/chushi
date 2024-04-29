class Api::V1::WorkspacesController < Api::ApiController
  before_action :verify_organization_access, :only => [:index]

  def index
    org = Organization.find(params[:organization_id])
    @workspaces = org.workspaces
    render json: @workspaces
  end

  def lock

  end

  def unlock

  end

  def state_versions

  end

  def current_state_version

  end

  def runs

  end
end
