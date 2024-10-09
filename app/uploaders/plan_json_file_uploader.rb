class PlanJsonFileUploader < CarrierWave::Uploader::Base
  storage :fog

  def initialize(*)
    super

    self.fog_directory = Chushi.storage.buckets.plans
  end

  def store_dir
    "#{model.id}/tfplan.json"
  end
end

# -[ RECORD 172 ]-+-------------------------------------
# id              | ac90c1bb-8e61-4a45-adc4-8895a0c29d51
# external_id     | cv-lPi7NSBZA95Mrs3E
# workspace_id    | 1710f517-b4cc-4849-b5df-07f2642b8fbb
# organization_id | 30648f7c-7201-49ba-a3d7-967bd56226d8
# source          |
# speculative     |
# status          | uploaded
# upload_url      |
# provisional     |
# created_at      | 2024-10-05 04:35:33.152707
# updated_at      | 2024-10-05 04:35:33.353136
# auto_queue_runs |