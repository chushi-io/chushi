class Organization < ApplicationRecord
  acts_as_taggable_on :tags

  has_many :workspaces

  has_many :organization_users
  has_many :agents
  has_many :users, through: :organization_users
  has_many :vcs_connections
  has_many :access_tokens, as: :token_authable
  has_many :plans
  has_many :applies
  has_many :runs
  has_many :run_tasks

  has_many :registry_modules
  has_many :providers
end
