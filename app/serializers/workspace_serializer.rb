# frozen_string_literal: true

class WorkspaceSerializer < ApplicationSerializer
  set_type :workspaces

  belongs_to :organization, serializer: ::OrganizationSerializer, id_method_name: :name, &:organization

  attribute :permissions do |_record|
    {
      'can-queue-run': true,
      'can-queue-apply': true,
      'can-queue-destroy': true
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
  attribute :structured_run_output_enabled do |_o|
    true
  end
  attribute :terraform_version, &:tofu_version
  attribute :trigger_prefixes do |_o|
    []
  end
  attribute :vcs_repo, if: proc { |record|
    record.vcs_repo_branch.present? || record.vcs_repo_identifier.present?
  } do |o|
    {
      branch: o.vcs_repo_branch,
      identifier: o.vcs_repo_identifier
    }
  end

  attribute :working_directory

  has_one :current_state_version, if: proc { |record|
    record.current_state_version.present?
  }, serializer: StateVersionSerializer, id_method_name: :external_id, &:current_state_version

  has_one :current_run, if: proc { |record|
    record.current_run.present?
  }, serializer: RunSerializer, id_method_name: :external_id, &:current_run

  has_one :current_configuration_version, if: proc { |record|
    record.current_configuration_version.present?
  }, serializer: ConfigurationVersionSerializer, id_method_name: :external_id, &:current_configuration_version

  belongs_to :agent_pool, serializer: AgentPoolSerializer, id_method_name: :external_id, &:agent_pool
  belongs_to :project, if: proc { |record|
    record.project.present?
  }, serializer: ProjectSerializer, id_method_name: :external_id, &:project
  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name, &:organization
  # attribute :setting_overwrites do |object| {} end
end
