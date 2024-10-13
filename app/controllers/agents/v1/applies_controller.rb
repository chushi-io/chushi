# frozen_string_literal: true

module Agents
  module V1
    class AppliesController < Agents::V1::AgentsController
      before_action :verify_run_access

      # Endpoint for agents to update run information
      def update
        @apply = Apply.find(params[:id])

        RunStatusUpdater.new(@apply.run).update_apply_status(params[:status]) if params[:status]

        render json: @apply
      end
    end
  end
end
