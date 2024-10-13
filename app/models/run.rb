class Run < ApplicationRecord
  belongs_to :organization
  belongs_to :workspace

  has_one :access_token, as: :token_authable

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
end
