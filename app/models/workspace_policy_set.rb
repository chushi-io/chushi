class WorkspacePolicySet < ApplicationRecord
  belongs_to :workspace
  belongs_to :policy_set
end
