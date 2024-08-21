class Registry::RegistryController < ActionController::API
  # TODO: This needs to be conditional in the event that a provider / module
  # is decided to be public
  before_action :verify_access_token
  before_action :load_organization

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

    @auth = @access_token
  end

  def load_organization
    @current_organization = Organization.find(request.headers['X-Chushi-Organization'].to_s)

    # Here we just verify access
    case @access_token.token_authable_type
    when "Organization"
      if @current_organization.id != @access_token.token_authable_id
        render json: nil, status: :forbidden
      end
    when "User"
      @user = User.find(@access_token.token_authable_id)
      # if @user.organizations
      # @current_organization = @user.organizations.find(request.headers['X-Chushi-Organization'].to_s)
      # puts @current_organization
    else
      render json: nil, status: :forbidden
    end
  end
end