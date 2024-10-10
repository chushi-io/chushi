class StateVersion < ApplicationRecord

  mount_uploader :state_file, StateVersionUploader
  mount_uploader :json_state_file, StateVersionJsonUploader

  belongs_to :run, optional: true
  belongs_to :workspace

  has_many :state_version_outputs

  before_create -> { generate_id("sv") }
end
