# frozen_string_literal: true

class TaskStageErroredJob
  include Sidekiq::Job

  def perform(*args); end
end
