class EvaluateOpenPolicyAgentJob
  include Sidekiq::Job

  def perform(_run_id, _policy)
    @run = Run.find(args.first)

    # Download the plan JSON
    # Build our input object
    input = build_opa_input

    @post_plan_stage = @run.task_stages.find { |task_stage| task_stage.stage == 'post_plan' }
    # If we don't have a post_plan stage, we don't have policy evaluations
    return if @post_plan_stage.nil?

    @policies.each do |policy|
      # Ensure the policy is created on the OPA server
      HTTParty.put("#{Chushi.opa.endpoint}/v1/policies/#{policy.id}")
      response = HTTParty.post("#{Chushi.opa.endpoint}/v1/query", {
                                 "query": policy.query,
                                 "input": input
                               })
      puts response
    end

    # Do something
    # Download the generated terraform plan
    # Evaluate Open Policy Agent against the plan
    # Stash the details as required
  end

  def build_opa_input
    {
      run: {
        id: @run.external_id,
        created_at: @run.created_at,
        created_by: nil,
        message: @run.message,
        commit_sha: nil,
        is_destroy: @run.is_destroy,
        refresh: @run.refresh,
        refresh_only: @run.refresh_only,
        replace_addrs: [],
        speculative: @run.speculative,
        target_addrs: [],
        project: {
          id: @run.workspace.project.id,
          name: @run.workspace.project.name
        },
        variables: {},
        organization: {
          name: @run.workspace.organization.name
        },
        workspace: {
          id: @run.workspace.external_id,
          name: @run.workspace.name,
          created_at: @run.workspace.created_at,
          description: @run.workspace.description,
          execution_mode: @run.workspace.execution_mode,
          auto_apply: @run.workspace.auto_apply,
          tags: @run.workspace.tag_list,
          working_directory: @run.workspace.working_directory,
          vcs_repo: {}
        }
      }
    }
  end
end
