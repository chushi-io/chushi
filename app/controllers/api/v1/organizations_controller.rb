class Api::V1::OrganizationsController < Api::ApiController
  def entitlements
    authorize!
    render json: {
      "data": {
        "id": params[:organization_id],
        "type": "entitlement-sets",
        "attributes": {
          "agents": true,
          "audit-logging": false,
          "configuration-designer": true,
          "cost-estimation": false,
          "global-run-tasks": false,
          "module-tests-generation": false,
          "operations": true,
          "policy-enforcement": false,
          "policy-limit": 5,
          "policy-mandatory-enforcement-limit": 0,
          "policy-set-limit": 1,
          "private-module-registry": true,
          "private-policy-agents": false,
          "private-vcs": false,
          "run-task-limit": 1,
          "run-task-mandatory-enforcement-limit": 1,
          "run-task-workspace-limit": 10,
          "run-tasks": false,
          "self-serve-billing": true,
          "sentinel": false,
          "sso": false,
          "state-storage": true,
          "teams": false,
          "usage-reporting": false,
          "user-limit": 5,
          "vcs-integrations": true,
          "versioned-policy-set-limit": 1
        },
        "links": {
          "self": "/api/v2/entitlement-sets/#{params[:organization_id]}"
        }
      }
    }

  end

  def queue
    authorize!
    @runs = Run.for_agent(current_agent.id).where(status: %w[plan_queued apply_queued])
    render json: ::RunSerializer.new(@runs, {}).serializable_hash
  end

  def tags
    @organization = Organization.find(params[:organization_id])
    if request.get?
      # Simply get the organization tags
    else
      tag_params=jsonapi_deserialize(params, only: [
        :id,
        :type,
      ])
      puts tag_params
      if request.post?

      elsif request.delete?

      end
    end
  end
end
