class RegistryModule < ApplicationRecord
  has_one_attached :archive
  # belongs_to :organization

  has_many :registry_module_versions, as: :versions
end
