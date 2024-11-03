# frozen_string_literal: true

class ApplyLogUploader < CarrierWave::Uploader::Base
  storage :fog

  def initialize(*)
    super

    self.fog_directory = Chushi.storage.buckets.applies
  end

  def store_dir
    model.id
  end

  def filename
    'logs'
  end
end
