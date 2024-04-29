class Organization < ApplicationRecord
  has_many :workspaces

  has_many :organization_users
  has_many :agents
  has_many :users, through: :organization_users
  has_many :vcs_connections
  has_many :access_tokens, as: :token_authable
end
