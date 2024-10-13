class PolicyEvaluation::PolicyEvaluationOverriddenJob
  include Sidekiq::Job

  def perform(*args); end
end
