class Api::V2::WorkspaceTasksController < Api::ApiController
  before_action :load_workspace
  def index
    render json: ::WorkspaceTaskSerializer.new(@workspace.tasks, {}).serializable_hash
  end

  def show
    @task = @workspace.tasks.find_by(external_id: params[:task_id])
    raise ActiveRecord::RecordNotFound unless @task
    render json: ::WorkspaceTaskSerializer.new(@task, {}).serializable_hash
  end

  def create
    puts task_params.class
    @run_task = RunTask.find_by(external_id: task_params["task_id"])

    @task = @workspace.tasks.new(task_params.except("task_id"))
    @task.run_task = @run_task
    if @task.save
      render json: ::WorkspaceTaskSerializer.new(@task, {}).serializable_hash
    else
      render json: @task.errors.full_messages, status: :bad_request
    end
  end

  def update
    @task = @workspace.tasks.find_by(external_id: params[:task_id])
    @task.update(task_params)
    render json: ::WorkspaceTaskSerializer.new(@task, {}).serializable_hash
  end

  def destroy
    authorize! @workspace, to: :manage_tasks?
    @task = @workspace.tasks.find_by(external_id: params[:task_id])
    TaskResult.delete_by(workspace_task_id: @task_id)
    @task.delete

    head :accepted
  end

  private
  def load_workspace
    @workspace = Workspace.where(external_id: params[:id]).or(Workspace.where(name: params[:id])).first
    raise ActiveRecord::RecordNotFound unless @workspace
    authorize! @workspace, to: :manage_tasks?
  end

  def task_params
    map_params([:task, :stage, :stages, "enforcement-level"])
  end
end
