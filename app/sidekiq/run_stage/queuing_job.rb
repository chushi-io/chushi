# frozen_string_literal: true

module RunStage
  class QueuingJob
    include Sidekiq::Job

    def perform(*args)
      @run = Run.find(args.first)
      @job = Job.new
      @job.run = @run
      @job.workspace = @run.workspace
      @job.agent_pool = @run.workspace.agent_pool
      @job.organization = @run.workspace.organization
      @job.locked = false
      @job.status = 'pending'
      @job.operation = 'plan'
      @job.save!

      # TODO: Check priority
      @run.update(status: 'plan_queued')
    end
  end
end
