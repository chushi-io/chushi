class WorkspaceSerializer < ApplicationSerializer
  set_type :workspaces

  belongs_to :organization, serializer: ::OrganizationSerializer, id_method_name: :name do |workspace|
    workspace.organization
  end

  attribute :permissions do |o|
    {
      "can-queue-run": true,
      "can-queue-apply": true,
      "can-queue-destroy": true,
    }
  end

  attribute :queue_all_runs

  attribute :allow_destroy_plan
  attribute :auto_apply
  attribute :auto_apply_run_trigger
  attribute :description
  attribute :environment
  attribute :execution_mode
  attribute :file_triggers_enabled
  attribute :global_remote_state
  attribute :latest_change_at
  attribute :locked
  attribute :name
  # attribute :operations

  attribute :policy_check_failures
  attribute :resource_count
  attribute :run_failures
  attribute :source
  attribute :speculative_enabled
  attribute :structured_run_output_enabled do |o| true end
  attribute :terraform_version do |object|
    object.tofu_version
  end
  attribute :trigger_prefixes
  attribute :vcs_repo, if: Proc.new { |record|
    record.vcs_repo_branch.present? || record.vcs_repo_identifier.present?
  } do |o|
    {
      "branch": o.vcs_repo_branch,
      "identifier": o.vcs_repo_identifier
    }
  end

  attribute :working_directory

  # has_one :current_state_version, serializer: StateVersionSerializer, id_method_name: :external_id do |object|
  #   object.current_state_version
  # end

  belongs_to :agent_pool, serializer: AgentPoolSerializer, id_method_name: :external_id do |object|
    object.agent_pool
  end

  # attribute :setting_overwrites do |object| {} end
end
