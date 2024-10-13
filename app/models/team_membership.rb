# frozen_string_literal: true

class TeamMembership < ApplicationRecord
  # belongs_to :organization
  belongs_to :team
  belongs_to :user

  before_create -> { generate_id('tu') }
end
