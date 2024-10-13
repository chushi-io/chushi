class Api::V2::StateVersionsController < Api::ApiController
  before_action :load_workspace, except: [:show]

  def index
    authorize! @workspace, to: :can_read_state_versions?
    versions = @workspace.state_versions
    render json: ::StateVersionSerializer.new(versions, {}).serializable_hash
  end

  def show
    @version = StateVersion.find_by(external_id: params[:id])
    authorize! @version.workspace, to: :can_read_state_versions?

    render json: ::StateVersionSerializer.new(@version, {}).serializable_hash
  end

  def create
    authorize! @workspace, to: :can_create_state_versions?
    version_params = jsonapi_deserialize(params, only: [
                                           # :force,
                                           # "json_state_outputs",
                                           # :lineage,
                                           # :md5,
                                           :serial,
                                           :run
                                         ])
    @version = @workspace.state_versions.create!(version_params)
    if @version
      render json: ::StateVersionSerializer.new(@version, {}).serializable_hash
    else
      head :bad_request
    end
  end

  def current
    authorize! @workspace, to: :can_read_state_versions?
    version = StateVersion.find(@workspace.current_state_version_id)
    if version
      render json: ::StateVersionSerializer.new(version, {}).serializable_hash
    else
      head :not_found
    end
  end

  def current_outputs
    authorize! @workspace, to: :can_read_state_outputs?
    @version = StateVersion.find(@workspace.current_state_version_id)
    render json: ::StateVersionOutputSerializer.new(@version.state_version_outputs, {}).serializable_hash
  end

  private

  def load_workspace
    @workspace = Workspace.where(external_id: params[:id]).or(Workspace.where(name: params[:id])).first
    raise ActiveRecord::RecordNotFound unless @workspace
  end
end
