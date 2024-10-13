class RegistryModule < ApplicationRecord
  belongs_to :organization

  has_many :registry_module_versions

  before_create -> { generate_id('mod') }
end
