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
    @plan = @organization.plans.new(
      execution_mode: @workspace.execution_mode,
      status: "pending"
    )
    @plan.save!
    unless @run.plan_only
      @apply = @organization.applies.new(
        execution_mode: @workspace.execution_mode
      )
      @apply.save!
    end
    @run.plan = @plan
    @run.apply = @apply
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
