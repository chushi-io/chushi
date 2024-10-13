class TeamsController < AuthenticatedController
  before_action :load_team, only: [:edit, :show, :update, :destroy]

  before_action -> {
    authorize! @organization, to: :can_create_team
  }, only: [:create]

  before_action -> {
    authorize! @team, to: :can_destroy?
  }, only: [:destroy]

  def index
    @teams = @organization.teams
  end

  def new
    @team = @organization.teams.new
  end

  def create
    @team = @organization.teams.new(team_params)
    if @team.save
      redirect_to team_path(@organization.name, @team.external_id)
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
    @team.destroy
    redirect_to teams_path(@organization.name)
  end

  private
  def load_team
    @team = @organization.teams.find_by(external_id: params[:id])
  end

  def team_params
    params.require(:team).permit(
      :name,
      :visibility,
      :sso_team_id,
    )
  end
end
