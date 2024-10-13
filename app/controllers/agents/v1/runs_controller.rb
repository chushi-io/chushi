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

  def token
    @token = AccessToken.where(
      token_authable_id: params[:id],
      token_authable_type: 'Run'
    ).first!
    render json: { token: @token.token }
  end

  private

  def update_params
    params.require(:run).permit(:status, :add, :change, :destroy)
  end
end
