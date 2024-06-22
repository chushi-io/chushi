class Policy < ApplicationRecord
  belongs_to :organization

  belongs_to :policy_set, optional: true
end
