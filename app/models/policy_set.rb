class PolicySet < ApplicationRecord
  belongs_to :organization
  has_many :policies

  before_create -> { generate_id("polset") }
end
