class Run < ApplicationRecord
  belongs_to :organization
  belongs_to :workspace

  has_one :access_token, as: :token_authable

  belongs_to :configuration_version, optional: true
  belongs_to :plan, optional: true
  belongs_to :apply, optional: true

  has_many :task_stages

  scope :for_agent, ->(agent_id) {
    left_joins(:workspace).where(workspaces: {agent_id: agent_id})
  }
  # pending	The initial status of a run after creation.
  # fetching	The run is waiting for HCP Terraform to fetch the configuration from VCS.
  # fetching_completed	HCP Terraform has fetched the configuration from VCS and the run will continue.
  # pre_plan_running	The pre-plan phase of the run is in progress.
  # pre_plan_completed	The pre-plan phase of the run has completed.
  # queuing	HCP Terraform is queuing the run to start the planning phase.
  # plan_queued	HCP Terraform is waiting for its backend services to start the plan.
  # planning	The planning phase of a run is in progress.
  # planned	The planning phase of a run has completed.
  # cost_estimating	The cost estimation phase of a run is in progress.
  # cost_estimated	The cost estimation phase of a run has completed.
  # policy_checking	The sentinel policy checking phase of a run is in progress.
  # policy_override	A sentinel policy has soft failed, and a user can override it to continue the run.
  # policy_soft_failed	A sentinel policy has soft failed for a plan-only run. This is a final state.
  # policy_checked	The sentinel policy checking phase of a run has completed.
  # confirmed	A user has confirmed the plan.
  # post_plan_running	The post-plan phase of the run is in progress.
  # post_plan_completed	The post-plan phase of the run has completed.
  # planned_and_finished	The run is completed. This status only exists for plan-only runs and runs that produce a plan with no changes to apply. This is a final state.
  # planned_and_saved	The run has finished its planning, checks, and estimates, and can be confirmed for apply. This status is only used for saved plan runs.
  # apply_queued	Once the changes in the plan have been confirmed, the run will transition to apply_queued. This status indicates that the run should start as soon as the backend services that run terraform have available capacity. In HCP Terraform, you should seldom see this status, as our aim is to always have capacity. However, in Terraform Enterprise this status will be more common due to the self-hosted nature.
  # applying	Terraform is applying the changes specified in the plan.
  # applied	Terraform has applied the changes specified in the plan.
  # discarded	The run has been discarded. This is a final state.
  # errored	The run has errored. This is a final state.
  # canceled	The run has been canceled.
  # force_canceled	A workspace admin forcefully canceled the run.


  # plan_only	The run does not have an apply phase. This is also called a speculative plan.
  # plan_and_apply	The run includes both plan and apply phases.
  # save_plan	The run is a saved plan run. It can include both plan and apply phases, but only becomes the workspace's current run if a user chooses to apply it.
  # refresh_only	The run should update Terraform state, but not make changes to resources.
  # destroy	The run should destroy all objects, regardless of configuration changes.
  # empty_apply	The run should perform an apply with no changes to resources. This is most commonly used to upgrade terraform state versions.

  # tfe-ui	Indicates a run was queued from HCP Terraform UI.
  # tfe-api	Indicates a run was queued from HCP Terraform API.
  # tfe-configuration-version	Indicates a run was queued from a Configuration Version, triggered from a VCS provider.
end
