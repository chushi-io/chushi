# frozen_string_literal: true

module RunStage
  class PrePlanCompletedJob
    include Sidekiq::Job

    def perform(*args)
      @run = Run.find(args.first)
      @run.update(status: 'queuing')
      RunStage::QueuingJob.perform_async(@run.id)
    end
  end
end
