class ProviderVersionUploader < CarrierWave::Uploader::Base
  storage :fog

  def initialize(*)
    super

    self.fog_directory = Chushi.storage.buckets.providers
  end

  def store_dir
    "private/#{model.namespace}/#{model.name}"
  end

  delegate :filename, to: :model

  def self.generate_url(_model)
    ''
  end
end
