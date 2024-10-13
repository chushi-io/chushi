class Plan::PlanRunningJob
  include Sidekiq::Job

  def perform(*args); end
end
