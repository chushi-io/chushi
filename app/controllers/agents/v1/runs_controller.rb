class Agents::V1::RunsController < Agents::V1::AgentsController
  before_action :verify_run_access

  # Endpoint for agents to update run information
  def update
    @run = Run.find(params[:id])
    if @run.update(update_params)
      render json: @run
    else
      render json: @run.errors.full_messages, status: :bad_request
    end
  end

  private
  def update_params
    params.require(:run).permit(:status, :add, :change, :destroy)
  end
end