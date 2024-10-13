class RunStage::RunPlannedJob
  include Sidekiq::Job

  def perform(*args); end
end
