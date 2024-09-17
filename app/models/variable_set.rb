class VariableSet < ApplicationRecord
  belongs_to :organization

  before_create -> { generate_id("varset") }

  has_many :variables
end
