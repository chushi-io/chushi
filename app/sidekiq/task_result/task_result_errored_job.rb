# frozen_string_literal: true

module TaskResult
  class TaskResultErroredJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
