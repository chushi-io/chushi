class Agents::V1::AgentsController < Api::ApiController
  before_action :authenticate_agent
  skip_verify_authorized

  protected
  def authenticate_agent
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

    unless @access_token.token_authable_type == "Agent"
      render json: nil, status: :forbidden
    end

    @agent = Agent.find(@access_token.token_authable_id)
  end

  def verify_run_access
    true
  end
end