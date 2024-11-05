# frozen_string_literal: true

class Run < ApplicationRecord
  belongs_to :organization
  belongs_to :workspace

  belongs_to :configuration_version, optional: true
  belongs_to :plan, optional: true
  belongs_to :apply, optional: true

  has_many :task_stages
  has_many :state_versions

  has_one :access_token, as: :token_authable

  scope :for_agent, lambda { |agent_id|
    left_joins(:workspace).where(workspaces: { agent_pool_id: agent_id })
  }

  before_create -> { generate_id('run') }

  def has_task_stage(stage)
    task_stages.find { |task_stage| task_stage.stage == stage }
  end

  def is_confirmable?
    return false unless status == 'planned_and_saved'

    if workspace.vcs_connection.present?
      # This should be updated to support VCS connections
      return false
    end

    true
  end
end
