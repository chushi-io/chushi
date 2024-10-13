# frozen_string_literal: true

module PolicyEvaluation
  class PolicyEvaluationErroredJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
