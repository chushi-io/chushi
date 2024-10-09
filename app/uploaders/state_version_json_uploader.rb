class StateVersionJsonUploader < CarrierWave::Uploader::Base
  storage :fog

  def initialize(*)
    super

    self.fog_directory = Chushi.storage.buckets.state_versions
  end

  def store_dir
    "#{model.id}/tfstate.json"
  end
end
