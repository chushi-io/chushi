# frozen_string_literal: true

class PlanRunningJob
  include Sidekiq::Job

  def perform(*args); end
end
