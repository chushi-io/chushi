class OrganizationsController < AuthenticatedController
  skip_before_action :set_organization!, except: [:show]

  def index
    @organizations = current_user.organizations
  end

  def new
    @organization = Organization.new
  end

  def show; end

  def create
    @organization = Organization.new(organization_params)
    # Attach the user to the organization
    @organization.users << current_user

    # Create the owners team, and add the user
    @owner_team = Team.new(name: "owners", visibility: "organization")
    @owner_team.users << current_user
    @organization.teams << @owner_team
    @organization.projects << Project.new(name: "Default Project")


    if @organization.save
      # TODO: Trigger a job to create
      # - default project
      # - default agent
      # - default team(s)
      redirect_to @organization
    else
      render :action => "new"
    end
  end

  def selector
    @organizations = current_user.organizations
    if request.post?
      session[:organization] = current_user.organizations.find(params[:organization_id]).id
      redirect_to workspaces_path
    else
      render "selector"
    end
  end

  private
  def organization_params
    params.require(:organization).permit(:name, :organization_type, :email)
  end
end
