class Team < ApplicationRecord
  belongs_to :organization
  has_many :team_projects
  has_many :projects, through: :team_projects

  has_many :team_memberships
  has_many :users, through: :team_memberships
  has_one :access_token, as: :token_authable
  before_create -> { generate_id('team') }
end
