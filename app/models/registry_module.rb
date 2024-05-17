class RegistryModule < ApplicationRecord
  has_one_attached :archive
  # belongs_to :organization
end
