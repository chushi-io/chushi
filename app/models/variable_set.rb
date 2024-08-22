class VariableSet < ApplicationRecord
  before_create -> { generate_id("varset") }
end
