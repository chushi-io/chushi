# frozen_string_literal: true

class Organization < ApplicationRecord
  @id_prefix = 'org'

  acts_as_taggable_on :tags
  acts_as_taggable_tenant :id

  attr_readonly :name

  has_many :workspaces

  has_many :agent_pools
  has_many :vcs_connections
  has_one :access_token, as: :token_authable
  has_many :plans
  has_many :applies
  has_many :runs
  has_many :run_tasks
  has_many :policies
  has_many :policy_sets
  has_many :projects
  has_many :teams
  has_many :team_projects
  has_many :variable_sets
  has_many :ssh_keys
  has_many :oauth_clients
  has_many :cloud_providers

  has_many :registry_modules
  has_many :providers

  has_many :organization_memberships
  has_many :users, through: :organization_memberships

  before_create -> { generate_id('org') }
end
