class TaskStage::TaskStageFailedJob
  include Sidekiq::Job

  def perform(*args)
    puts "Ope, our task stage failed"
  end
end