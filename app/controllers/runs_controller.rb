class RunsController < AuthenticatedController
  before_action :set_workspace
  def index
    @runs = @workspace.runs
  end

  def show
    @run = @workspace.runs.find(params[:id])
  end

  def new
    @run = Run.new
  end

  def create
    @run = @workspace.runs.new(run_params)
    @run.organization = @organization
    if @run.save
      GenerateConfigurationVersionJob.perform_async(@run.id)
      flash[:info] = "Run created"
      redirect_to @workspace
    else
      flash[:error] = @run.errors.full_messages
      render "new"
    end
  end

  private
  def set_workspace
    @workspace = @organization.workspaces.find(params[:workspace_id])
  end

  def run_params
    params.require(:run).permit(:plan_only, :message)
  end
end
