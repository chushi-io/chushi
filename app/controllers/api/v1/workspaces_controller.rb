class Api::V1::WorkspacesController < Api::ApiController

  def index
    org = Organization.find(params[:organization_id])
    @workspaces = org.workspaces
    render json: @workspaces
  end

  def lock

  end

  def unlock

  end

  def show
    # TODO: Hack to only support agents for now
    puts "Are we even getting here?"
    puts @agent
    @workspace = @organization.workspaces.find(params[:id])
    render json: @workspace
  end

  def state_versions

  end

  def current_state_version

  end

  def runs

  end
end
