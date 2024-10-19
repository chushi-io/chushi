# frozen_string_literal: true

class PlanRedactedJsonUploader < CarrierWave::Uploader::Base
  storage :fog

  def initialize(*)
    super

    self.fog_directory = Chushi.storage.buckets.plans
  end

  def store_dir
    model.id
  end

  def filename
    'redacted.json'
  end
end
