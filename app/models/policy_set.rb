# frozen_string_literal: true

class PolicySet < ApplicationRecord
  belongs_to :organization
  has_many :policies

  has_many :workspace_policy_sets
  has_many :workspaces, through: :workspace_policy_sets

  before_create -> { generate_id('polset') }
end
