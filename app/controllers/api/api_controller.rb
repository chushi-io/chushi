class Api::ApiController < ActionController::API
  before_action :set_default_response_format
  before_action :verify_access_token

  protected

  def set_default_response_format
    request.format = :json
  end

  def verify_access_token
    token = request.headers['Authorization'].to_s.split(' ').last
    @access_token = AccessToken.find_by_token(token)

    if @access_token.nil?
      puts "Access Token is nil"
      render json: nil,  status: :forbidden and return
    end

    if @access_token.expires_at.present? && @access_token.expires_at < Time.now
      puts "Access token is expired"
      render json: nil, status: :forbidden
    end
  end

  def current_organization
    if @access_token.token_authable_type == "Organization"
      Organization.find(@access_token.token_authable_id)
    end
  end

  def current_user
    if @access_token.token_authable_type == "User"
      User.find(@access_token.token_authable_id)
    end
  end

  def verify_organization_access
    if current_organization
      render json: {}, status: :forbidden unless current_organization.id == params[:organization_id]
      @organization = current_organization
    else
      @organization = current_user.organizations.find(params[:organization_id])
      render json: {}, status: :forbidden unless @organization
    end
  end

  def can_access_workspace(workspace)
    ## TODO for now, we just verify access to the organization
    can_access_organization(workspace.organization_id)
  end

  def can_access_organization(organization_id)
    if current_organization && current_organization != organization_id
      false
    else
      unless current_user.organizations.find(organization_id)
        false
      end
    end
    true
  end
end