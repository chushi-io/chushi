class OrganizationsController < AuthenticatedController
  skip_before_action :set_organization!, except: [:show]

  before_action lambda {
    authorize! current_user, to: :can_create_organizations
  }, only: %i[new create]
  def index
    @organizations = current_user.organizations
  end

  def show; end

  def new
    @organization = Organization.new
  end

  def create
    authorize! current_user, to: :can_create_organizations?

    @organization = Organization.new(organization_params)
    # Attach the user to the organization
    @organization.users << current_user

    # Create the owners team, and add the user
    @owner_team = Team.new(name: 'owners', visibility: 'organization')
    @owner_team.users << current_user
    @organization.teams << @owner_team
    @organization.projects << Project.new(name: 'Default Project')

    if @organization.save
      redirect_to @organization
    else
      render action: 'new'
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :organization_type, :email)
  end
end
