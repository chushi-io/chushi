class Api::V2::WorkspacesController < Api::ApiController
  before_action :load_workspace, except: [:index, :create]

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
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :create_workspaces?

    @workspace = @org.workspaces.new(workspace_params)
    if @workspace.save
      render json: ::WorkspaceSerializer.new(@workspace, {}).serializable_hash
    else
      render json: @workspace.errors.full_messages, status: :bad_request
    end
  end

  def update
    # JSONAPI::De
    authorize! @workspace

    if @workspace.update(workspace_params)
      render json: ::WorkspaceSerializer.new(@workspace, {}).serializable_hash
    else
      render json: @workspace.errors.full_messages, status: :bad_request
    end
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

  def runs

  end

  def tags
    authorize! @workspace
    params.permit!

    if request.get?
      # Simply get the workspace tags
    else
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
    @workspace = Workspace.where(external_id: params[:id]).or(Workspace.where(name: params[:id])).first
    raise ActiveRecord::RecordNotFound unless @workspace
  end

  def workspace_params
    map_params([
      :name,
      "agent-pool-id",
      "allow-destroy-plan",
      "auto-apply",
      "auto-apply-run-trigger",
      "auto-destroy-at",
      "auto-destroy-at-activity-duration",
      "description",
      "execution-mode",
      "file-triggers-enabled",
      "global-remote-state",
      "queue-all-runs",
      "source-name",
      "source-url",
      "speculative-enabled",
      "terraform-version",
      "trigger-patterns",
      "trigger-prefixes",
      "working-directory",
               ])
  end
end
