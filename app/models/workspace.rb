class Workspace < ApplicationRecord
  acts_as_taggable_on :tags
  belongs_to :organization
  belongs_to :vcs_connection
  has_many :runs
  has_many :configuration_versions
  has_many :state_versions

  has_many :variables
end
