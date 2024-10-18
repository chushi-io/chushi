# frozen_string_literal: true

# When an agent wants to query jobs, its a 3 stage process
# - List all the available jobs for a given agent
# - When we want to execute a job, we create an exclusive lock on the job
# - The agent then queries the job again, ensuring its locked
# - The agent processes the job per usual
# - Upon completion, and updating the run resource, we mark as finished
module Api
  module V2
    class JobsController < Api::ApiController
      before_action :load_job, except: [:index]

      # This endpoint may optionally have an agent ID. If it does
      # we query jobs for a specific agent. Otherwise, we query jobs
      def index
        skip_verify_authorized!

        head :forbidden and return unless current_agent && current_agent.id == params[:id]

        @jobs = Job
                .select('DISTINCT ON (workspace_id) *')
                .where(agent_pool_id: params[:id])
                .where(locked: false)
                .order(workspace_id: :asc, created_at: :desc)
                .limit(10)
        render json: ::JobSerializer.new(@jobs, {}).serializable_hash
      end

      def show
        authorize! @job
        render json: ::JobSerializer.new(@job, {}).serializable_hash
      end

      def lock
        authorize! @job
        head :conflict and return if @job.locked

        @job.update(locked_by: params['locked_by'], locked: true)
        render json: ::JobSerializer.new(@job, {}).serializable_hash
      end

      def unlock
        authorize! @job
        head :conflict and return unless @job.locked
        head :bad_request and return unless @job.locked_by == params[:locked_by]

        @job.update(locked: false)
        render json: ::JobSerializer.new(@job, {}).serializable_hash
      end

      def update
        authorize! @job
        @job.update(job_params)
        Rails.logger.debug { "Job status: #{@job.status}" }
        JobFinishedJob.perform_async(@job.id) if %w[completed errored].include?(@job.status)
        render json: ::JobSerializer.new(@job, {}).serializable_hash
      end

      def destroy
        authorize! @job
        @job.delete
        head :no_content
      end

      private

      def job_params
        map_params(%i[status locked_by])
      end

      def load_job
        @job = Job.find(params[:id])
        raise ActiveRecord::RecordNotFound unless @job
      end
    end
  end
end
