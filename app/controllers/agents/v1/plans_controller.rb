class Agents::V1::PlansController < Agents::V1::AgentsController
  before_action :verify_run_access

  # Endpoint for agents to update run information
  def update
    @run = Run.find(params[:id])

    request.body.rewind
    @run.plan.plan_file.attach(io: request.body, filename: "plan")

    render json: @plan
  end
end