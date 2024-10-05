class RunTasksController < AuthenticatedController
  before_action :load_run_task, only: [:edit, :show, :update, :destroy]
  def index
    @run_tasks = @organization.run_tasks
  end

  def new
    @run_task = @organization.run_tasks.new
  end

  def create
    @run_task = @organization.run_tasks.new(run_task_params)
    @run_task.category = "task"
    if @run_task.save
      redirect_to run_task_path(@organization.name, @run_task.external_id)
    else
      render "new"
    end
  end

  def show

  end

  def edit

  end

  def update

  end

  def destroy
    if @run_task.destroy
      redirect_to run_tasks_path(@organization.name)
    else
      render "show"
    end
  end

  private
  def load_run_task
    @run_task = @organization.run_tasks.find_by(external_id: params[:id])
  end

  def run_task_params
    params.require(:run_task).permit(
      :category,
      :name,
      :url,
      :hmac_key,
      :enabled,
      :description
    )
  end
end
