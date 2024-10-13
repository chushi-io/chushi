# frozen_string_literal: true

module TaskStage
  class TaskStageErroredJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
