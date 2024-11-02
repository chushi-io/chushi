# frozen_string_literal: true

class JobFinishedJob
  include Sidekiq::Job

  def perform(*args)
    @job = Job.find(args.first)
    if @job.operation == 'plan'
      if @job.status == 'completed'
        @job.run.plan.update(status: 'finished')
        if @job.run.plan_only
          @job.run.update(status: 'planned_and_finished')
        else
          @job.run.update(status: 'planned_and_saved')
        end
      else
        @job.run.plan.update(status: 'errored')
        @job.run.update(status: 'errored')
      end
    elsif @job.operation == 'apply'
      if @job.status == 'completed'
        @job.run.apply.update(status: 'finished')
        @job.run.update(status: 'applied')
      else
        @job.run.apply.update(status: 'errored')
        @job.run.update(status: 'errored')
      end
    end
  end
end
