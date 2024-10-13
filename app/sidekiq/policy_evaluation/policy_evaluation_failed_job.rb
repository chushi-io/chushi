class PolicyEvaluation::PolicyEvaluationFailedJob
  include Sidekiq::Job

  def perform(*args); end
end
