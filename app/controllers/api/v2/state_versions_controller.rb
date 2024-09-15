class Api::V2::StateVersionsController < Api::ApiController
  before_action :load_workspace, :except => [:show, :state, :state_json, :upload_state, :upload_state_json]
  skip_verify_authorized :only => [:upload_state, :upload_state_json, :state, :state_json]
  skip_before_action :verify_access_token, :only => [:upload_state, :upload_state_json]

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

  def show
    @version = StateVersion.find_by(external_id: params[:id])
    authorize! @version.workspace, to: :show?

    render json: ::StateVersionSerializer.new(@version, {}).serializable_hash
  end

  def state


    @version = StateVersion.find_by(external_id: params[:id])
    head :no_content and return unless @version.state_file.attached?
    render plain: @version.state_file.download, layout: false, content_type: 'text/plain'
  end

  def state_json
    @version = StateVersion.find_by(external_id: params[:id])
    head :no_content and return unless @version.json_state_file.attached?
    render plain: @version.json_state_file.download, layout: false, content_type: 'text/plain'
  end

  def upload_state
    @version = StateVersion.find_by(external_id: params[:id])
    request.body.rewind
    @version.state_file.attach(io: request.body, filename: "state")
    @version.workspace.update(current_state_version_id: @version.id)
    render plain: nil, status: :created
  end

  def upload_state_json
    @version = StateVersion.find_by(external_id: params[:id])
    request.body.rewind
    @version.json_state_file.attach(io: request.body, filename: "json_state")
    head :ok
  end

  private
  def load_workspace
    @workspace = Workspace.where(external_id: params[:id]).or(Workspace.where(name: params[:id])).first
    raise ActiveRecord::RecordNotFound unless @workspace
  end
end