class Api::V2::RunTasksController < Api::ApiController
  def index
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :can_read_run_tasks?

    @tasks = @org.run_tasks
    render ::RunTaskSerializer.new(@tasks, {}).serializable_hash
  end

  def show
    @task = RunTask.find_by(external_id: params[:id])
    authorize! @org, to: :can_read_run_tasks?
    render json: ::RunTaskSerializer.new(@task, {}).serializable_hash
  end

  def create
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :can_manage_run_tasks?

    @task = @org.run_tasks.new(task_params)
    if @task.save
      render json: ::RunTaskSerializer.new(@task, {}).serializable_hash
    else
      render json: @task.errors.full_messages, status: :bad_request
    end
  end

  def update
    @task = RunTask.find_by(external_id: params[:id])
    authorize! @task.organization, to: :can_manage_run_tasks?
    if @task.update(task_params)
      render json: ::RunTaskSerializer.new(@task, {}).serializable_hash
    else
      render json: @task.errors.full_messages, status: :bad_request
    end
  end

  def destroy
    @task = RunTask.find_by(external_id: params[:id])
    authorize! @task.organization, to: :can_manage_run_tasks?
    if @task.delete
      render status: :no_content
    else
      render status: :internal_server_error
    end
  end

  private

  def task_params
    map_params([
                 :url,
                 :name,
                 :enabled,
                 'hmac-key',
                 :description,
                 :category
                 # TODO: We won't currently support global-configuration
                 # "global-configuration"
               ])
  end
end
