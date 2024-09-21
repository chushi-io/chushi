class TaskResult::TaskResultErroredJob
  include Sidekiq::Job

  def perform(*args)

  end
end
