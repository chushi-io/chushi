class StateVersionOutput < ApplicationRecord
  before_create -> { generate_id("wsout") }
end
