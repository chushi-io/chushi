# frozen_string_literal: true

module TaskStage
  class TaskStageFailedJob
    include Sidekiq::Job

    def perform(*_args)
      Rails.logger.debug 'Ope, our task stage failed'
    end
  end
end
