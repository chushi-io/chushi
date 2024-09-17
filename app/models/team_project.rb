class TeamProject < ApplicationRecord
  belongs_to :organization
  belongs_to :team
  belongs_to :project

  before_create -> { generate_id("tprj") }
end
