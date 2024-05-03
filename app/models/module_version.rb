class ModuleVersion < ApplicationRecord
  has_one_attached :archive

  belongs_to :registry_module
end
