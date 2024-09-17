class Api::V2::OrganizationMembershipsController < Api::ApiController
  def index
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :list_memberships?

    @memberships = @org.organization_memberships
    render json: ::OrganizationMembershipSerializer.new(@memberships, {}).serializable_hash
  end

  def create
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :create_memberships?

    @membership = @org.organization_memberships.new
    @user = User.find_by(email: membership_params["email"])
    @membership.email = membership_params["email"]
    if @user
      # We'll attribute the user object directly as well
      @membership.user = @user
    end

    if @membership.save
      render json: ::OrganizationMembershipSerializer.new(@membership, {}).serializable_hash
    else
      render json: @membership.errors.full_messages, status: :bad_request
    end
  end

  def show
    @membership = OrganizationMembership.find_by(external_id: params[:id])
    unless @membership
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @membership
    render json: ::OrganizationMembershipSerializer.new(@membership, {
      :include => [:user],
    }).serializable_hash
  end

  def update

  end

  def destroy
    @membership = OrganizationMembership.find_by(external_id: params[:id])
    unless @membership
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @membership
    if @membership.delete
      render status: :no_content
    else
      render status: :internal_server_error
    end
  end

  private
  def membership_params
    map_params([:email, :teams])
  end
end
