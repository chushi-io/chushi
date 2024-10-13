class TaskStage::TaskStageFailedJob
  include Sidekiq::Job

  def perform(*_args)
    puts 'Ope, our task stage failed'
  end
end
