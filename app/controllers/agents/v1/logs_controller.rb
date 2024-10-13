# frozen_string_literal: true

module Agents
  module V1
    class LogsController < Agents::V1::AgentsController
      before_action :verify_run_access

      def create; end
    end
  end
end
