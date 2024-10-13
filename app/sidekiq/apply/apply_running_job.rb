# frozen_string_literal: true

module Apply
  class ApplyRunningJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
