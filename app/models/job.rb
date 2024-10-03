class Job < ApplicationRecord
  belongs_to :organization
  belongs_to :agent, :class_name => "Agent", optional: true
  belongs_to :workspace
  belongs_to :run

end
