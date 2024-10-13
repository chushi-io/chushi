class ProjectsController < AuthenticatedController
  before_action :load_project, only: [:edit, :show, :update, :destroy]

  before_action -> {
    authorize! @organization, to: :can_create_project?
  }, only: [:create]

  before_action -> {
    authorize! @project, to: :can_update?
  }, only: [:update]

  before_action -> {
    authorize! @project, to: :can_destroy?
  }

  def index
    @projects = @organization.projects
  end

  def new
    @project = @organization.projects.new
  end

  def create
    authorize! @organization, to: :can_create_project?
    @project = @organization.projects.new(project_params)
    if @project.save
      redirect_to project_path(@organization.name, @project.external_id)
    else
      render "new"
    end
  end

  def show

  end

  def edit

  end

  def update

  end

  def destroy
    authorize! @project, to: :can_destroy?
    if @project.destroy
      redirect_to projects_path(@organization.name)
    else
      render :show
    end
  end

  private
  def load_project
    @project = @organization.projects.find_by(external_id: params[:id])
  end
  def project_params
    params.require(:project).permit(:name, :description)
  end
end
