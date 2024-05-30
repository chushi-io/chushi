class Api::V1::RunsController < Api::ApiController
  before_action :load_run, :except => [:create]
  def create
    run_params=jsonapi_deserialize(params, only: [
      "plan-only",
      :message,
      :workspace,
      "configuration_version"
    ])
    @workspace = Workspace.find(run_params["workspace_id"])
    authorize! @workspace, to: :create_run?



    @run = @workspace.organization.runs.new(run_params)
    @run.workspace = @workspace
    begin
      RunCreator.call(@run)
      render json: ::RunSerializer.new(@run, {}).serializable_hash
    rescue => exception
      render status: :internal_server_error
    end
  end

  def show
    authorize! @run

    options = {}
    options[:include] = params[:include].split(",") if params[:include]
    render json: ::RunSerializer.new(@run, options).serializable_hash
  end

  def discard
    authorize! @run
  end

  def cancel
    authorize! @run
  end

  def force_cancel
    authorize! @run
  end

  def force_execute
    authorize! @run
  end

  def events
    authorize! @run
    render json: {}
  end

  private
  def load_run
    @run = Run.find(params[:id])
  end
end
