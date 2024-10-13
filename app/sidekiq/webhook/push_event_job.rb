class Webhook::PushEventJob
  include Sidekiq::Job

  # This event handler only handles pushes to the default branch
  # Pull Request pushes should trigger separate workflows from
  # the pull request handler
  def perform(*args)
    value = Rails.cache.read(args.first)

    # Find all affected workspaces, and trigger a run if needed
    Workspace.where(
      vcs_repo_identifier: value['repository']['full_name'],
      execution_mode: %w[remote agent],
      vcs_repo_branch: value['ref'].split('/').last
    ).each do |workspace|
      # Ignore if installation ID does not match the webhook
      return if workspace.vcs_connection.github_installation_id != value['installation']['id']

      # TODO: Evaluate if its a plan or apply
      # TODO: Check if workspace should plan on push event at all
      run = workspace.organization.runs.new
      run.plan_only = false
      run.auto_apply = workspace.auto_apply
      run.trigger_reason = 'push_event'
      run.workspace = workspace

      RunCreator.call(run)
    end
  end
end
