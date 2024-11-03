# frozen_string_literal: true

class Workspace < ApplicationRecord
  acts_as_taggable_on :tags
  acts_as_taggable_tenant :organization_id

  belongs_to :organization
  belongs_to :vcs_connection, optional: true
  has_many :runs
  has_many :configuration_versions
  has_many :state_versions
  has_many :notification_configurations

  has_many :tasks, class_name: 'WorkspaceTask'
  has_many :variables

  has_many :run_triggers
  belongs_to :project, optional: true

  has_many :workspace_policy_sets
  has_many :policy_sets, through: :workspace_policy_sets

  has_many :workspace_teams
  has_many :teams, through: :workspace_teams

  belongs_to :current_configuration_version, class_name: 'ConfigurationVersion', optional: true
  belongs_to :current_state_version, class_name: 'StateVersion', optional: true
  belongs_to :current_run, class_name: 'Run'

  belongs_to :agent_pool, optional: true

  before_create -> { generate_id('ws') }

  def permissions
    {
      'can-update' => true
    }
  end
end
