# frozen_string_literal: true

class StateVersionJsonUploader < CarrierWave::Uploader::Base
  storage :fog

  def initialize(*)
    super

    self.fog_directory = Chushi.storage.buckets.state_versions
  end

  def store_dir
    model.id
  end

  def filename
    'state.json'
  end

  def self.generate_url(_model)
    ''
  end
end
