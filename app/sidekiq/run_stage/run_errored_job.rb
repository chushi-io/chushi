# frozen_string_literal: true

module RunStage
  class RunErroredJob
    include Sidekiq::Job

    def perform(*args); end
  end
end
