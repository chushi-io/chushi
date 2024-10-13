class Api::V2::WorkspaceTeamsController < Api::ApiController
  def index
    skip_verify_authorized!
    head :not_implemented
  end

  def create
    @workspace = Workspace.find_by(external_id: workspace_team_params["workspace_id"])
    @team = Team.find_by(external_id: workspace_team_params["team_id"])
    unless @workspace && @team
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @workspace, to: :is_admin?
    @workspace_team = WorkspaceTeam.new(workspace_team_params)
    @workspace_team.workspace = @workspace
    @workspace_team.team = @team
    @workspace_team.organization = @workspace.organization

    if @workspace_team.save
      render json: ::WorkspaceTeamSerializer.new(@workspace_team, {}).serializable_hash
    else
      render json: @workspace_team.errors.full_messages, status: :bad_request
    end
  end

  def show
    @workspace_team = WorkspaceTeam.find_by(external_id: params[:id])
    unless @workspace_team
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @workspace_team.workspace, to: :is_admin?
    render json: ::WorkspaceTeamSerializer.new(@workspace_team, {}).serializable_hash
  end

  def update
    @workspace_team = WorkspaceTeam.find_by(external_id: params[:id])
    unless @workspace_team
      skip_verify_authorized!
      head :not_found and return
    end
    authorize! @workspace_team.workspace, to: :is_admin?
    if @workspace_team.update(workspace_team_params)
      render json: ::WorkspaceTeamSerializer.new(@workspace_team, {}).serializable_hash
    else
      render json: @workspace_team.errors.full_messages, status: :bad_request
    end
  end

  def destroy
    @workspace_team = WorkspaceTeam.find_by(external_id: params[:id])
    unless @workspace_team
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @workspace_team.workspace, to: :is_admin?
    if @workspace_team.delete
      head :accepted
    else
      render json: @workspace_team.errors.full_messages, status: :bad_request
    end
  end

  private
  def workspace_team_params
    map_params([
      :workspace,
      :team,
      :access,
      :runs,
      :variables,
      "state-versions",
      "workspace-locking",
      "run-tasks"
               ])
  end
end
