class WorkspaceSerializer
  include JSONAPI::Serializer
  set_key_transform :dash

  set_type :workspaces

  attribute :permissions do |o|
    {
      "can-queue-run": true,
      "can-queue-apply": true,
      "can-queue-destroy": true,
    }
  end

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
  attribute :vcs_repo
  attribute :vcs_repo_identifier
  attribute :working_directory

  has_one :current_state_version, serializer: :state_version
end
