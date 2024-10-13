# frozen_string_literal: true

module Apply
  class ApplyErroredJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
