class ConfigurationVersionUploadedJob
  include Sidekiq::Job

  def perform(*args)
    @version = ConfigurationVersion.find(args.first)

    # TODO: Check if we have pre_plan tasks scheduled. If
    # we do, we can set to "pre_plan_running". Since we don't
    # currently support them, we'll send it straight to "plan_queued"

    # TODO: We also might  not want to set it directly to
    # "plan_queued", we may eventually want "queuing"
    return unless @version.auto_queue_runs

    @version.runs.where(status: 'fetching').update(status: 'plan_queued')
  end
end
