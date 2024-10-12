class ModuleVersionUploader < CarrierWave::Uploader::Base
  storage :fog

  def initialize(*)
    super

    self.fog_directory = Chushi.storage.buckets.modules
  end

  def store_dir
    "private/#{model.registry_module.namespace}/#{model.registry_module.name}/#{model.registry_module.provider}"
  end

  def filename
    model.version
  end
end
