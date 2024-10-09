class PlanFileUploader < CarrierWave::Uploader::Base
  storage :fog

  def initialize(*)
    super

    self.fog_directory = Chushi.storage.buckets.plans
  end

  def store_dir
    "#{model.id}/tfplan"
  end
end
