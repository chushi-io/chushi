# frozen_string_literal: true

module Plan
  class PlanErroredJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
