# frozen_string_literal: true

module PolicyEvaluation
  class PolicyEvaluationOverriddenJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
