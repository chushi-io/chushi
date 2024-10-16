# frozen_string_literal: true

class VariablesController < AuthenticatedController
  before_action lambda {
    authorize! @organization, to: :can_read_varsets?
  }, only: %i[index]

  before_action lambda {
    authorize! @organization, to: :can_manage_varsets?
  }, only: %i[new create]

  def index
    @variables = @organization.variables
  end

  def new
    @workspace = Workspace.find(params[:workspace]) if params[:type] == 'workspace'
    @variable = Variable.new
  end

  def create
    @variable = if variable_params[:workspace]
                  Workspace.find(variable_params[:workspace]).variables.new(variable_params.except(:workspace))
                else
                  Variable.new(variable_params)
                end
    @variable.save!

    flash[:info] = 'Variable created'
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
