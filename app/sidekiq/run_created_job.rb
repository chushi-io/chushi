class RunCreatedJob
  include Sidekiq::Job

  def perform(*args)
    @run = Run.find(args.first)

    if @run.configuration_version.status == "uploaded"
      @run.update(status: "plan_queued")
    end
  end
end
