# frozen_string_literal: true

class RunConfirmedJob
  include Sidekiq::Job

  def perform(*args)
    @run = Run.find(args.first)

    # If the job has pre_apply task stages
    # we would initiate those here. At the
    # moment, we're going to pun support for
    # executing those

    # Short circuit the run to 'apply_queued' and
    # create the job for the agent to pick up
    @run.update(status: 'apply_queued')
    Job.create!(
      organization_id: @run.workspace.organization_id,
      workspace_id: @run.workspace.id,
      run_id: @run.id,
      status: 'pending',
      operation: 'apply',
      locked: false,
      agent_pool_id: @run.workspace.agent_pool_id
    )
  end
end
