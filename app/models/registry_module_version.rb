class RegistryModuleVersion < ApplicationRecord
  belongs_to :registry_module

  mount_uploader :archive, ModuleVersionUploader
  before_create -> { generate_id('modver') }
end
