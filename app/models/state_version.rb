class StateVersion < ApplicationRecord
  has_one_attached :state_file
  has_one_attached :json_state_file

  belongs_to :run, optional: true
  belongs_to :workspace

  has_many :state_version_outputs

  before_create -> { generate_id("sv") }
end
