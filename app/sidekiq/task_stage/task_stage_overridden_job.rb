# frozen_string_literal: true

module TaskStage
  class TaskStageOverriddenJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
