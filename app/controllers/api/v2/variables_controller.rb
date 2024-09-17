class Api::V2::VariablesController < Api::ApiController
  skip_verify_authorized

  def index
    if params[:workspace_id]
      @variables = Workspace.find(params[:workspace_id]).variables
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
