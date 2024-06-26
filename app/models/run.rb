class Run < ApplicationRecord
  belongs_to :organization
  belongs_to :workspace

  has_one :access_token, as: :token_authable

  belongs_to :configuration_version, optional: true
  belongs_to :plan, optional: true
  belongs_to :apply, optional: true

  has_many :task_stages
  has_many :state_versions

  scope :for_agent, ->(agent_id) {
    left_joins(:workspace).where(workspaces: {agent_id: agent_id})
  }
end
