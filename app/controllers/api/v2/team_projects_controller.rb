class Api::V2::TeamProjectsController < Api::ApiController
  # To view projects
  # - If a non-admin user, show projects they have access to
  # - If admin user, show all projects in the organization
  # TODO: Permission checks on this controller still need to be updated
  def index
    skip_verify_authorized!
    authorize! current_organization, to: :list_team_projects?
    @team_projects = current_organization.team_projects

    render json: ::TeamProjectSerializer.new(@team_projects, {}).serializable_hash
  end

  def show
    @team_project = TeamProject.find_by(external_id: params[:id])
    unless @team_project
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @team_project
    render json: ::TeamProjectSerializer.new(@team_project, {}).serializable_hash
  end

  def create
    authorize! current_organization, to: :create_team_projects?
    @team = current_organization.teams.find_by!(external_id: team_project_params['team_id'])
    @project = current_organization.projects.find_by!(external_id: team_project_params['project_id'])

    @team_project = current_organization.team_projects.new(access: team_project_params['access'])
    @team_project.team = @team
    @team_project.project = @project

    if @team_project.save
      render json: ::TeamProjectSerializer.new(@team_project, {}).serializable_hash
    else
      render json: @team_project.errors.full_messages, status: :bad_request
    end
  end

  def update
    @team_project = TeamProject.find_by(external_id: params[:id])
    unless @team_project
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @team_project

    @team_project.access = team_project_params['access']
    if @team_project.save
      render json: ::TeamProjectSerializer.new(@team_project, {}).serializable_hash
    else
      render json: @team_project.errors.full_messages, status: :bad_request
    end
  end

  def destroy
    @team_project = TeamProject.find_by(external_id: params[:id])
    authorize! @team_project
    if @team_project.delete
      render status: :no_content
    else
      render status: :internal_server_error
    end
  end

  private

  def team_project_params
    map_params([
                 :access,
                 'project-access',
                 'workspace-access',
                 :project,
                 :team
               ])
  end
end
