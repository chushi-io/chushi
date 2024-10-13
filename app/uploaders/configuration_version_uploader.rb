# frozen_string_literal: true

class ConfigurationVersionUploader < CarrierWave::Uploader::Base
  storage :fog

  def store_dir
    model.id
  end

  def filename
    'archive.tar.gz'
  end

  def initialize(*)
    super

    self.fog_directory = Chushi.storage.buckets.configuration_versions
  end
end
