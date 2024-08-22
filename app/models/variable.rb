class Variable < ApplicationRecord
  before_create -> { generate_id("var") }
end
