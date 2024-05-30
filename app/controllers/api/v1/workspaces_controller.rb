class Api::V1::WorkspacesController < Api::ApiController
  before_action :load_workspace, :except => [:index]

  def index
    @org = Organization.find(params[:organization_id])
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

    if @workspace.locked
      head :bad_request
    end
    @workspace.update(locked: true)
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

  def show
    authorize! @workspace
    render json: ::WorkspaceSerializer.new(@workspace, {}).serializable_hash
  end

  def state_versions
    authorize! @workspace, to: :show?
    versions = @workspace.state_versions
    render json: ::StateVersionSerializer.new(versions, {}).serializable_hash
  end

  def current_state_version
    authorize! @workspace, to: :show?
    version = @workspace.state_versions.first
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
    @workspace = Workspace.where(id: params[:id]).or(Workspace.where(name: params[:id])).first
  end
end
