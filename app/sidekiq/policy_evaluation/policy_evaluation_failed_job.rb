# frozen_string_literal: true

module PolicyEvaluation
  class PolicyEvaluationFailedJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
