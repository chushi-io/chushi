# frozen_string_literal: true

module RunStage
  class FetchingCompletedJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
