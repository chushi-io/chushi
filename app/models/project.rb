# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :organization

  has_many :team_projects
  has_many :teams, through: :team_projects

  before_create -> { generate_id('prj') }
end
