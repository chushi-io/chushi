# frozen_string_literal: true

class TaskResultFailedJob
  include Sidekiq::Job

  def perform(*args); end
end
