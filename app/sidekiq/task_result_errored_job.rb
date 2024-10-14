# frozen_string_literal: true

class TaskResultErroredJob
  include Sidekiq::Job

  def perform(*args); end
end
