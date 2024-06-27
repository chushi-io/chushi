class Webhook::PullRequestJob
  include Sidekiq::Job

  def perform(*args)
    value = Rails.cache.read(args.first)

    # Skip any actions that aren't supported
    supported_actions = %w[synchronize opened ready_for_review reopened]
    unless supported_actions.include?(value["action"])
      return
    end

    # Find all affected workspaces, and trigger a run if needed
    Workspace.where(
      vcs_repo_identifier: value["repository"]["full_name"],
      execution_mode: %w[remote agent],
      vcs_repo_branch: value["pull_request"]["base"]["ref"].split('/').last
    ).each do |workspace|
      # Ignore if installation ID does not match the webhook
      if workspace.vcs_connection.github_installation_id != value["installation"]["id"]
        return
      end

      # TODO: Evaluate if its a plan or apply
      # TODO: Check if workspace should plan on pull request event at all
      run = workspace.organization.runs.new
      run.plan_only = true
      run.workspace = workspace
      begin
        RunCreator.call(run)
      end
    end
  end
end
