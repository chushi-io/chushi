class Job::JobFinishedJob
  include Sidekiq::Job

  def perform(*args)
    @job = Job.find(args.first)
    if @job.operation == "plan"
      if @job.status == "completed"
        @job.run.plan.update(status: "finished")
      else
        @job.run.plan.update(status: "errored")
      end
    elsif @job.operation == "apply"
      if @job.status == "completed"
        @job.run.apply.update(status: "finished")
      else
        @job.run.apply.update(status: "errored")
      end
    end
  end
end