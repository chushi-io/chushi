class Policy < ApplicationRecord
  belongs_to :organization
  belongs_to :policy_set, optional: true
  before_create -> { generate_id("pol") }
end
