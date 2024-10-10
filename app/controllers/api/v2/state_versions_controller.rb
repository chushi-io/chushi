class Api::V2::StateVersionsController < Api::ApiController
  before_action :load_workspace, :except => [:show]

  def index
    authorize! @workspace, to: :show?
    versions = @workspace.state_versions
    render json: ::StateVersionSerializer.new(versions, {}).serializable_hash
  end

  def create
    authorize! @workspace, to: :state_version_state?
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
    authorize! @workspace, to: :show?
    version = StateVersion.find(@workspace.current_state_version_id)
    if version
      render json: ::StateVersionSerializer.new(version, {}).serializable_hash
    else
      head :not_found
    end
  end

  def current_outputs
    authorize! @workspace, to: :show?
    @version = StateVersion.find(@workspace.current_state_version_id)
    render json: ::StateVersionOutputSerializer.new(@version.state_version_outputs, {}).serializable_hash
  end

  def show
    @version = StateVersion.find_by(external_id: params[:id])
    authorize! @version.workspace, to: :show?

    render json: ::StateVersionSerializer.new(@version, {}).serializable_hash
  end

  private
  def load_workspace
    @workspace = Workspace.where(external_id: params[:id]).or(Workspace.where(name: params[:id])).first
    raise ActiveRecord::RecordNotFound unless @workspace
  end
end