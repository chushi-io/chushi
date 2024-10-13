class ProviderVersionUploader < CarrierWave::Uploader::Base
  storage :fog

  def initialize(*)
    super

    self.fog_directory = Chushi.storage.buckets.providers
  end

  def store_dir
    "private/#{model.namespace}/#{model.name}"
  end

  def filename
    model.filename
  end

  def self.generate_url(_model)
    ''
  end
end
