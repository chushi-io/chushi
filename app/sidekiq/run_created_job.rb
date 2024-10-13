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
    end
  end
end
