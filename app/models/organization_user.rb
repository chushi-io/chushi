class OrganizationUser < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  before_create -> { generate_id("ou") }
end
