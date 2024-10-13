class Apply::ApplyErroredJob
  include Sidekiq::Job

  def perform(*args); end
end
