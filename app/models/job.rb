class Job < ApplicationRecord
  belongs_to :organization
  belongs_to :agent_pool, optional: true
  belongs_to :workspace
  belongs_to :run

end
