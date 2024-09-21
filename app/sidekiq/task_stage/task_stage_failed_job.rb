class TaskStage::TaskStageFailedJob
  include Sidekiq::Job

  def perform(*args)

  end
end