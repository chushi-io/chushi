class WorkspaceTeam < ApplicationRecord
  belongs_to :organization
  belongs_to :workspace
  belongs_to :team

  before_create -> { generate_id("tws") }
end
