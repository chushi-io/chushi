# frozen_string_literal: true

class RunCreatedJob
  include Sidekiq::Job

  def perform(*args)
    @run = Run.find(args.first)

    return unless @run.configuration_version.status == 'uploaded'

    if @run.task_stages.any? { |task_stage| task_stage.stage == 'pre_plan' }
      @run.update(status: 'pre_plan_running')
      RunStage::PrePlanRunningJob.perform_async(@run.id)
    else
      @run.update(status: 'plan_queued')
      Job.create!(
        organization_id: @run.workspace.organization_id,
        workspace_id: @run.workspace.id,
        run_id: @run.id,
        status: 'pending',
        operation: 'plan',
        agent_pool_id: @run.workspace.agent_pool_id
      )
    end
  end
end
