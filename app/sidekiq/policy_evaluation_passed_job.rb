# frozen_string_literal: true

class PolicyEvaluationPassedJob
  include Sidekiq::Job

  def perform(*args)
    @policy_evaluation = PolicyEvaluation.find(args.first)
  end
end
