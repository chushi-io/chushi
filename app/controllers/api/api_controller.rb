class Api::ApiController < ActionController::API
  include JSONAPI::Deserialization
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

    if @access_token.expires_at.present? && @access_token.expires_at.after?(Time.now)
      puts "Access token is expired"
      render json: nil, status: :forbidden
    end
  end

  def current_organization
    if @access_token.token_authable_type == "Organization"
      Organization.find(@access_token.token_authable_id)
    end
  end

  def is_organization
    @access_token.token_authable_type == "Organization"
  end

  def is_user
    @access_token.token_authable_type == "User"
  end
  def current_user
    if @access_token.token_authable_type == "User"
      User.find(@access_token.token_authable_id)
    end
  end

  def current_agent
    if @access_token.token_authable_type == "Agent"
      Agent.find(@access_token.token_authable_id)
    end
  end

  def verify_organization_access
    if current_organization
      render json: {}, status: :forbidden unless current_organization.id == params[:organization_id]
      @organization = current_organization
    elsif current_user
      @organization = current_user.organizations.find(params[:organization_id])
      render json: {}, status: :forbidden unless @organization
    else
      @agent = current_agent
      @organization = @agent.organization
    end
  end

  def can_access_workspace(workspace)
    if current_agent
      return workspace.agent_id == current_agent.id
    end
    ## TODO for now, we just verify access to the organization
    can_access_organization(workspace.organization_id)
  end

  def can_access_run(run)
    if current_agent
      return run.agent_id == current_agent.id
    end
    can_access_organization(run.organization_id)
  end

  def can_access_organization(organization_id)
    puts organization_id
    if current_organization && current_organization != organization_id
      false
    elsif current_agent
      return current_agent.organization.id == organization_id
    else
      puts current_user.organizations.map{ |org| org.id }
      unless current_user.organizations.find(organization_id)
        return false
      end
    end
    true
  end
end