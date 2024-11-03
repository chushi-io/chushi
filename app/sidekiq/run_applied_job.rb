class RunAppliedJob
  include Sidekiq::Job

  def perform(*args)
    @run = Run.find(args.first)
    # Update as current run
    @run.workspace.update(current_run: @run)
  end
end
