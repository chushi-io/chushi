class Api::V2::WorkspacesController < Api::ApiController
  before_action :load_workspace, :except => [:index, :state_version_state, :state_version_state_json, :get_state_version]
  skip_before_action :verify_access_token, :only => [:state_version_state, :state_version_state_json]
  skip_verify_authorized :only => [:state_version_state, :state_version_state_json]

  def index
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :list_workspaces?

    @workspaces = @org.workspaces
    if params[:search]
      if params[:search][:tags]
        @workspaces = @workspaces.tagged_with(params[:search][:tags].split(","), :match_all => true)
      end
    end
    render json: ::WorkspaceSerializer.new(@workspaces, {}).serializable_hash
  end

  def lock
    authorize! @workspace
    head :conflict and return if @workspace.locked
    @workspace.update(locked: true)
    render json: ::WorkspaceSerializer.new(@workspace, {}).serializable_hash
  end

  def create

  end

  def update
    # JSONAPI::De
    authorize! @workspace
    #
    patch_params=jsonapi_deserialize(params)
    puts patch_params
    if patch_params.key?("vcs-repo")
      if patch_params["vcs-repo"] == nil
        @workspace.vcs_repo_branch = nil
        @workspace.vcs_repo_branch = nil
      else
        # Set the VCS repo configuration
      end
    end
    # @workspace.update!(jsonapi_deserialize(params))
    # end
    if patch_params.key?("auto-apply")
      puts patch_params["auto-apply"]
      @workspace.auto_apply = patch_params["auto-apply"]
    end
    if patch_params.key?("file-triggers-enabled")
      @workspace.file_triggers_enabled = patch_params["file-triggers-enabled"]
    end
    if patch_params.key?("queue-all-runs").present?
      @workspace.queue_all_runs = patch_params["queue-all-runs"]
    end

    @workspace.save!
    render json: ::WorkspaceSerializer.new(@workspace, {}).serializable_hash
  end

  def unlock
    authorize! @workspace
    unless @workspace.locked
      head :bad_request
    end
    @workspace.update(locked: false)
    render json: ::WorkspaceSerializer.new(@workspace, {}).serializable_hash
  end

  def force_unlock
    authorize! @workspace
    unless @workspace.locked
      head :bad_request and return
    end
    @workspace.update(locked: false)
    render json: ::WorkspaceSerializer.new(@workspace, {}).serializable_hash
  end

  def show
    authorize! @workspace
    render json: ::WorkspaceSerializer.new(@workspace, {}).serializable_hash
  end

  def state_versions
    if request.get?
      authorize! @workspace, to: :show?
      versions = @workspace.state_versions
      render json: ::StateVersionSerializer.new(versions, {}).serializable_hash
    else
      authorize! @workspace, to: :state_version_state?
      puts params
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
        puts @version.errors.full_messages
        head :bad_request
      end
    end
  end

  def current_state_version
    authorize! @workspace, to: :show?
    version = StateVersion.find(@workspace.current_state_version_id)
    if version
      render json: ::StateVersionSerializer.new(version, {}).serializable_hash
    else
      head :not_found
    end
  end

  def runs

  end

  def tags
    authorize! @workspace
    params.permit!

    if request.get?
      # Simply get the workspace tags
    else
      puts tag_params
      if request.post?

      elsif request.delete?

      end
    end
  end

  def get_state_version
    @version = StateVersion.find_by(external_id: params[:id])
    authorize! @version.workspace, to: :show?

    render json: ::StateVersionSerializer.new(@version, {}).serializable_hash
  end

  def state_version_state
    # @workspace = Workspace.where(id: params[:id]).or(Workspace.where(name: params[:id])).first
    # authorize! @workspace, to: :show?
    @version = StateVersion.find_by(external_id: params[:id])

    if request.get?
      head :no_content and return unless @version.state_file.attached?

      render plain: @version.state_file.download, layout: false, content_type: 'text/plain'
    else
      puts "Authorizing"
      # authorize! @version.workspace, to: :state_version_state?
      puts "Uploading file"
      request.body.rewind
      @version.state_file.attach(io: request.body, filename: "state")
      puts "Updating workspace with new state version"
      @version.workspace.update(current_state_version_id: @version.id)
      render plain: nil, status: :created



    end
  end

  def state_version_state_json
    # @workspace = Workspace.where(id: params[:id]).or(Workspace.where(name: params[:id])).first
    # authorize! @workspace, to: :show?
    @version = StateVersion.find_by(external_id: params[:id])

    if request.get?
      head :no_content and return unless @version.json_state_file.attached?

      render plain: @version.json_state_file.download, layout: false, content_type: 'text/plain'
    else
      request.body.rewind
      @version.json_state_file.attach(io: request.body, filename: "json_state")
      head :ok
    end
  end

  private
  def tag_params
    params.permit(
      [
        :type,
        attributes: [ :name ]
      ],
      :id
    )
  end

  private
  def load_workspace
    @workspace = Workspace.where(external_id: params[:id]).or(Workspace.where(name: params[:id])).first
    raise ActiveRecord::RecordNotFound unless @workspace
  end
end
