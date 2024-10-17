class ProviderVersionShasumsUploader < CarrierWave::Uploader::Base
  storage :fog

  def initialize(*)
    super

    self.fog_directory = Chushi.storage.buckets.providers
  end

  def store_dir
    "private/#{model.provider.namespace}/#{model.provider.name}/#{model.version}"

  end

  def filename
    'shasums'
  end
end
