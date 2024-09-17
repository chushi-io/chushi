class Api::V2::TeamsController < Api::ApiController
  def index
    @org = Organization.find_by(external_id: params[:organization_id])
    authorize! @org, to: :list_teams?

    @teams = @org.teams
    render json: ::TeamSerializer.new(@teams, {}).serializable_hash
  end

  def create
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :create_teams?

    @team = @org.teams.new(team_params)
    if @team.save
      render json: ::TeamSerializer.new(@team, {}).serializable_hash
    else
      render json: @team.errors.full_messages, status: :bad_request
    end
  end

  def show
    @team = Team.find_by(external_id: params[:id])
    unless @team
      skip_verify_authorized!
      head :not_found and return
    end
    authorize! @team
    render json: ::TeamSerializer.new(@team, {}).serializable_hash
  end

  def update
    @team = Team.find_by(external_id: params[:id])
    authorize! @team
    if @team.update(team_params)
      render json: ::TeamSerializer.new(@team, {}).serializable_hash
    else
      render json: @team.errors.full_messages, status: :bad_request
    end
  end

  def destroy
    @team = Team.find_by(external_id: params[:id])
    authorize! @team
    if @team.delete
      render status: :no_content
    else
      render status: :internal_server_error
    end
  end

  def add_users

  end

  def remove_users

  end

  def add_org_memberships

  end

  def remove_org_memberships

  end

  private
  def team_params
    map_params([
                 :name,
                 :description,
                 :visibility,
                 "allow-member-token-management"
               ])
  end
end
