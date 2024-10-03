# When an agent wants to query jobs, its a 3 stage process
# - List all the available jobs for a given agent
# - When we want to execute a job, we create an exclusive lock on the job
# - The agent then queries the job again, ensuring its locked
# - The agent processes the job per usual
# - Upon completion, and updating the run resource, we mark as finished
class Api::V2::JobsController < Api::ApiController
  before_action :load_job, except: [:index]

  # This endpoint may optionally have an agent ID. If it does
  # we query jobs for a specific agent. Otherwise, we query jobs
  def index
    skip_verify_authorized!
    puts current_agent.id
    puts params[:id]
    unless current_agent && current_agent.id == params[:id]
      head :forbidden and return
    end
    @jobs = Job.
      select('DISTINCT ON (workspace_id) *').
      where(agent_id: params[:id]).
      where(locked: false).
      order(workspace_id: :asc, created_at: :desc).
      limit(10)
    render json: ::JobSerializer.new(@jobs, {}).serializable_hash
  end

  def show
    authorize! @job
    render json: ::JobSerializer.new(@job, {}).serializable_hash
  end

  def lock
    authorize! @job
    if @job.locked
      head :conflict and return
    end
    @job.update(locked_by: params["locked_by"], locked: true)
    render json: ::JobSerializer.new(@job, {}).serializable_hash
  end

  def unlock
    authorize! @job
    unless @job.locked
      head :conflict and return
    end
    unless @job.locked_by == params[:locked_by]
      head :bad_request and return
    end
    @job.update(locked: false)
    render json: ::JobSerializer.new(@job, {}).serializable_hash
  end

  def update
    authorize! @job
    @job.update(job_params)
    puts "Job status: #{@job.status}"
    if %w[completed errored].include?(@job.status)
      Job::JobFinishedJob.perform_async(@job.id)
    end
    render json: ::JobSerializer.new(@job, {}).serializable_hash
  end

  def destroy
    authorize! @job
    @job.delete
    head :no_content
  end

  private
  def job_params
    map_params([:status, :locked_by])
  end

  def load_job
    @job = Job.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @job
  end
end
