class Plan::PlanFinishedJob
  include Sidekiq::Job

  def perform(*args)
    @plan = Plan.find(args.first)
    if @plan.status == 'finished'
      @plan.run.update(status: 'planned')
      RunStage::RunPlannedJob.perform_async(@plan.run.id)
    elsif @plan.status == 'errored'
      @plan.run.update(status: 'errored')
      RunStage::RunErroredJob.perform_async(@plan.run.id)
    end
  end
end
