class RunsController < AuthenticatedController
  before_action :set_workspace
  before_action -> {
    authorize! @workspace, to: :access?
  }, only: [:index, :show]

  before_action -> {
    authorize! @workspace, to: :can_queue_run?
  }, only: [:new, :create]

  def index
    @runs = @workspace.runs
  end

  def show
    @run = @workspace.runs.find_by(external_id: params[:id])
  end

  def new
    @run = Run.new
  end

  def create
    if run_params["plan_only"]
      authorize! @workspace, to: :can_queue_run?
    else
      authorize! @workspace, to: :can_queue_apply?
    end
    @run = @workspace.runs.new(run_params)
    @run.organization = @organization
    begin
      RunCreator.call(@run)
      flash[:info] = "Run created"
      redirect_to @workspace
    rescue => exception
      flash[:error] = @run.errors.full_messages
      render "new"
    end
  end

  private
  def set_workspace
    @workspace = @organization.workspaces.find_by(external_id: params[:workspace_id])
  end

  def run_params
    params.require(:run).permit(:plan_only, :message)
  end
end
