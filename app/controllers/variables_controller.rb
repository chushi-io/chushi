class VariablesController < AuthenticatedController
  
  def index
    @variables = @organization.variables
  end

  def new
    if params[:type] == "workspace"
      @workspace = Workspace.find(params[:workspace])
    end
    @variable = Variable.new
  end

  def create
    if variable_params[:workspace]
      @variable = Workspace.find(variable_params[:workspace]).variables.new(variable_params.except(:workspace))
    else
      @variable = Variable.new(variable_params)
    end
    @variable.save!

    flash[:info] = "Variable created"
    if variable_params[:workspace]
      redirect_to workspace_path(Workspace.find(variable_params[:workspace]))
    else
      redirect_to variables_path
    end
  end

  private
  def variable_params
    params.require(:variable).permit(:name, :value, :description, :workspace, :variable_type)
  end
end
