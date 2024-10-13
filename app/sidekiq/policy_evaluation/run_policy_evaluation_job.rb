# frozen_string_literal: true

module PolicyEvaluation
  class RunPolicyEvaluationJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
