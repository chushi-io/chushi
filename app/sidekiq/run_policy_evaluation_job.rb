# frozen_string_literal: true

class RunPolicyEvaluationJob
  include Sidekiq::Job

  def perform(*args); end
end
