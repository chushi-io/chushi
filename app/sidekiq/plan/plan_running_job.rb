# frozen_string_literal: true

module Plan
  class PlanRunningJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
