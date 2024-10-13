class Api::V2::VariablesController < Api::ApiController
  skip_verify_authorized

  def index
    if params[:workspace_id]
      @workspace = Workspace.find_by(external_id: params[:workspace_id])
      authorize! @workspace, to: :can_read_variable
      @variables = @workspace.variables
    else
      @variables = []
    end

    render json: ::VariableSerializer.new(@variables, {}).serializable_hash
  end

  def create

  end

  def update

  end

  def destroy

  end
end
