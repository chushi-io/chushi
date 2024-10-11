class Api::V2::RunsController < Api::ApiController
  before_action :load_run, :except => [:create]
  def create
    @workspace = Workspace.find_by(external_id: run_params["workspace_id"])
    authorize! @workspace, to: :create_run?

    @run = @workspace.organization.runs.new(run_params)
    if run_params["configuration_version_id"]
      @run.configuration_version = ConfigurationVersion.find_by(external_id: run_params["configuration_version_id"])
    end
    @run.workspace = @workspace
    begin
      RunCreator.call(@run)
      render json: ::RunSerializer.new(@run, {}).serializable_hash
    rescue => exception
      puts exception
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

  def update
    authorize! @run

    render json: ::RunSerializer.new(@run, {}).serializable_hash
  end

  def apply
    authorize! @run
    @run.update(status: "apply_queued")
    render json: ::RunSerializer.new(@run, {}).serializable_hash
  end

  def token
    authorize! @run, to: :token?
    @access_token = Doorkeeper::AccessToken.new(
      application_id: Doorkeeper::Application.first.id
    )
    @access_token.resource_owner = @run
    @access_token.save!
    @id_token = Doorkeeper::OpenidConnect::IdToken.new(@access_token)
    render json: {
      token: @id_token.as_jws_token
    }
  end

  def identity_token
    authorize! @run, to: :token?

  end

  private
  def load_run
    @run = Run.find_by(external_id: params[:id])
  end

  def run_params
    map_params([
                 "plan-only",
                 :message,
                 :workspace,
                 "is-destroy",
                 "configuration-version"
               ])
  end
end
