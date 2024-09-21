class TaskResult::TaskResultPassedJob
  include Sidekiq::Job

  def perform(*args)

  end
end