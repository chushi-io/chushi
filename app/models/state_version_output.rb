class StateVersionOutput < ApplicationRecord
  belongs_to :state_version

  before_create -> { generate_id("wsout") }
end
