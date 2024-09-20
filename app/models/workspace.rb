class Workspace < ApplicationRecord
  acts_as_taggable_on :tags
  belongs_to :organization
  belongs_to :vcs_connection, optional: true
  has_many :runs
  has_many :configuration_versions
  has_many :state_versions
  has_many :notification_configurations

  has_many :tasks, :class_name => "WorkspaceTask"
  has_many :variables

  has_many :run_triggers

  before_create -> { generate_id("ws") }
end
