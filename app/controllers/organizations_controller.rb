class OrganizationsController < AuthenticatedController
  skip_before_action :set_organization!

  def index
    @organizations = current_user.organizations
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.users << current_user

    if @organization.save
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
    params.require(:organization).permit(:name, :organization_type)
  end

end
