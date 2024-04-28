class Run < ApplicationRecord
  belongs_to :organization
  belongs_to :workspace

  belongs_to :configuration_version, optional: true
  belongs_to :plan, optional: true
  belongs_to :apply, optional: true
end
