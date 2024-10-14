# frozen_string_literal: true

class PlanErroredJob
  include Sidekiq::Job

  def perform(*args); end
end
