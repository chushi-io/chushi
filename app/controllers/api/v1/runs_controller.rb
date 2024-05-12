class Api::V1::RunsController < Api::ApiController
  before_action :can_create_run, only: :create

  def create
    run_params=jsonapi_deserialize(params, only: [
      "plan-only",
      :message,
      :workspace,
      "configuration_version"
    ])
    render json: nil
    # @run = @organization.runs.new(run_params)
  end

  def discard

  end

  def cancel

  end

  def force_cancel

  end

  def force_execute

  end

  private
  def can_create_run
    true
  end
end
