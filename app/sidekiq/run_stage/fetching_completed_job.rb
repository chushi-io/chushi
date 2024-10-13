class RunStage::FetchingCompletedJob
  include Sidekiq::Job

  def perform(*args); end
end
