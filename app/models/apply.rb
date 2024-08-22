class Apply < ApplicationRecord
  has_one :run
  has_many :state_versions
  before_create -> { generate_id("apool") }
end
