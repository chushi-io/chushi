class TaskResult::TaskResultFailedJob
  include Sidekiq::Job

  def perform(*args); end
end
