# frozen_string_literal: true

class PolicyEvaluationErroredJob
  include Sidekiq::Job

  def perform(*args); end
end
