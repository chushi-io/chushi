class WorkspacesController < AuthenticatedController
  def index
    @workspaces = @organization.workspaces
  end

  def show
    @workspace = @organization.workspaces.find_by(external_id: params[:id])
    @runs = @workspace.runs.order('created_at desc').limit(10)
  end

  def new
    @workspace = Workspace.new
    @vcs_connections = @organization.vcs_connections
  end

  def create
    if workspace_params[:project_id]
      @project = Project.find_by(external_id: workspace_param[:project_id])
      authorize! @project, to: :can_create_workspace?
    end
    @workspace = @organization.workspaces.new(workspace_params)
    if @workspace.save
      flash[:info] = 'Workspace created'
      redirect_to @workspace
    else
      flash[:error] = 'Failed creating workspace'
      render 'new'
    end
  end

  def update; end

  def destroy
    if @organization.workspaces.destroy(params[:id])
      redirect_to workspaces_path(@organization.name)
    else
      flash[:error] = 'Failed deleting workspace'
    end
  end

  private

  def workspace_params
    params.require(:workspace).permit(
      :name,
      :description,
      :environment,
      :execution_mode,
      :tofu_version,
      :auto_apply,
      :allow_destroy_plan,
      :vcs_connection_id,
      :working_directory,
      :source
    )
  end
end
