class Workspace < ApplicationRecord
  belongs_to :organization
  belongs_to :vcs_connection
  has_many :runs
  has_many :configuration_versions
end
