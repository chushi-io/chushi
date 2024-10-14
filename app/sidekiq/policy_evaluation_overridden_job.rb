# frozen_string_literal: true

class PolicyEvaluationOverriddenJob
  include Sidekiq::Job

  def perform(*args); end
end
