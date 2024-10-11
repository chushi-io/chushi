class PolicyUploader < CarrierWave::Uploader::Base
  storage :fog

  def initialize(*)
    super

    self.fog_directory = Chushi.storage.buckets.policies
  end

  def store_dir
    model.id
  end

  def filename
    "policy.rego"
  end
end
