class Agents::V1::AppliesController < Agents::V1::AgentsController
  before_action :verify_run_access

  # Endpoint for agents to update run information
  def update
    @apply = Apply.find(params[:id])

    if params[:status]
      RunStatusUpdater.new(@apply.run).update_apply_status(params[:status])
    end

    render json: @apply
  end
end