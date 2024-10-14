# frozen_string_literal: true

class PolicyEvaluationFailedJob
  include Sidekiq::Job

  def perform(*args); end
end
