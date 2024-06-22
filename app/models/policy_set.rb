class PolicySet < ApplicationRecord
  belongs_to :organization

  has_many :policies
end
