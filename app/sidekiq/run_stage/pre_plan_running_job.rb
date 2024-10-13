# frozen_string_literal: true

module RunStage
  class PrePlanRunningJob
    include Sidekiq::Job

    def perform(*args)
      @run = Run.find(args.first)

      @run.task_stages.each do |task_stage|
        if task_stage.stage == 'pre_plan'
          TaskStage::ExecuteTaskStageJob.perform_async(task_stage.id)
          return
        end
      end

      @run.update(status: 'queuing')
      RunStage::QueuingJob.perform_async(@run.id)
    end
  end
end
