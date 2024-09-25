class RunStage::QueuingJob
  include Sidekiq::Job

  def perform(*args)
    @run = Run.find(args.first)
    @run.update(status: "plan_queued")
  end
end