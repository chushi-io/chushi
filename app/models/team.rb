class Team < ApplicationRecord
  belongs_to :organization
  has_many :team_projects
  has_many :projects, through: :team_projects
  before_create -> { generate_id("team") }
end
