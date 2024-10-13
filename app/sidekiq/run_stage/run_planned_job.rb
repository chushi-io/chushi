# frozen_string_literal: true

module RunStage
  class RunPlannedJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
