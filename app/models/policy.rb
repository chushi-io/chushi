class Policy < ApplicationRecord
  belongs_to :organization
  belongs_to :policy_set, optional: true

  mount_uploader :policy, PolicyUploader

  before_create -> { generate_id("pol") }
end
