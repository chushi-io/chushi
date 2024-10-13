# frozen_string_literal: true

module Agents
  module V1
    class PlansController < Agents::V1::AgentsController
      before_action :verify_run_access

      # Endpoint for agents to update run information
      def update
        @plan = Plan.find(params[:id])

        RunStatusUpdater.new(@plan.run).update_plan_status(params[:status]) if params[:status]

        render json: @plan
      end
    end
  end
end

# 22:59:20 server.1   | Started GET "/api/v1/plans/b8e6fd60-1ddd-498f-834a-704f787e8eed/logs?limit=65536&offset=0" for 74.70.224.53 at 2024-05-28 22:59:20 -0400
# 22:59:20 server.1   | Cannot render console from 74.70.224.53! Allowed networks: 127.0.0.0/127.255.255.255, ::1
# 22:59:20 server.1   | Processing by Api::V1::PlansController#logs as JSON
# 22:59:20 server.1   |   Parameters: {"limit"=>"65536", "offset"=>"0", "id"=>"b8e6fd60-1ddd-498f-834a-704f787e8eed"}
# 22:59:20 server.1   | Completed 204 No Content in 0ms (ActiveRecord: 0.0ms | Allocations: 27)
# 22:59:20 server.1   |
# 22:59:20 server.1   |
# 22:59:20 sidekiq.1  | 2024-05-29T02:59:20.231Z pid=1681 tid=
