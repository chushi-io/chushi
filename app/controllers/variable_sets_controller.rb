class VariableSetsController < AuthenticatedController
  before_action :load_variable_set, only: [:show, :edit, :update, :destroy]
  before_action -> {
    authorize! @organization, to: :can_read_varsets?
  }, only: [:index, :show]

  before_action -> {
    authorize! @organization, to: :can_manage_varsets?
  }, only: [:new, :create, :edit, :update, :destroy]

  def index
    @variable_sets = @organization.variable_sets
  end

  def show

  end

  def create
    @variable_set = @organization.variable_sets.new(variable_set_params)
    if @variable_set.save
      redirect_to variable_set_path(@organization.name, @variable_set.external_id)
    else
      render "new"
    end
  end

  def new
    @variable_set = @organization.variable_sets.new
  end

  def edit

  end

  def update

  end

  def destroy
    if @variable_set.destroy
      redirect_to variable_sets_path(@organization.name)
    else
      render :show
    end
  end

  private
  def load_variable_set
    @variable_set = @organization.variable_sets.find_by(external_id: params[:id])
  end

  def variable_set_params
    params.require(:variable_set).permit(
      :name,
      :description,
      :auto_attach,
      :priority
    )
  end
end
