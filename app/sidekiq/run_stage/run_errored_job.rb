class RunStage::RunErroredJob
  include Sidekiq::Job

  def perform(*args); end
end
