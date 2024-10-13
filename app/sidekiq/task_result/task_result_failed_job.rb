# frozen_string_literal: true

module TaskResult
  class TaskResultFailedJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
