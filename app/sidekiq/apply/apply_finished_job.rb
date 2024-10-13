# frozen_string_literal: true

module Apply
  class ApplyFinishedJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
