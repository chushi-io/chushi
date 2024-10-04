class RunStage::QueuingJob
  include Sidekiq::Job

  def perform(*args)
    @run = Run.find(args.first)
    @job = Job.new
    @job.run = @run
    @job.workspace = @run.workspace
    @job.agent = @run.workspace.agent_pool
    @job.organization = @run.workspace.organization
    @job.locked = false
    @job.status = 'pending'
    @job.operation = 'plan'
    @job.save!

    # TODO: Check priority
    @run.update(status: "plan_queued")
  end
end