# frozen_string_literal: true

class TaskStageOverriddenJob
  include Sidekiq::Job

  def perform(*args); end
end
