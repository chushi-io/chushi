# frozen_string_literal: true

class TaskStageFailedJob
  include Sidekiq::Job

  def perform(*_args)
    Rails.logger.debug 'Ope, our task stage failed'
  end
end
