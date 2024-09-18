class Api::V2::AuthenticationTokensController < Api::ApiController
  before_action :get_token, only: [:get_team_token, :get_agent_token, :show, :destroy_team_token, :destroy]
  def index

  end

  def list_team_tokens
    # @org = Organization.find_by(name: params[:organization_id])
    # @tokens = AccessToken.
    #   where(token_authable_type: "Team").
    #   joins(:teams).where('' => time_range)
  end

  def get_team_token
    @team = Team.find_by(external_id: params[:id])
    unless @team
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @team, to: :create_access_token?
    if @team.access_token.nil?
      skip_verify_authorized!
      head :not_found and return
    end
    render json: ::AuthenticationTokenSerializer.new(@team.access_token, {}).serializable_hash
  end

  def create_team_token
    @team = Team.find_by(external_id: params[:id])
    unless @team
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @team, to: :create_access_token?
    @token = @team.access_token
    if @token
      @team.generate_access_token
      @team.expired_at = token_params["expired_at"]
    else
      @token = AccessToken.new(token_params)
      @token.token_authable = @team
      @token.save!
    end

    if @token.save
      render json: ::AuthenticationTokenSerializer.new(@token, {
        params: { show_token: true }
      }).serializable_hash
    else
      render json: @token.errors.full_messages, status: :bad_request
    end
  end

  def destroy_team_token

  end

  def create_organization_token
    @org = Organization.find_by(name: params[:organization_id])
    unless @org
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @org, to: :create_access_token?
    @token = @org.access_token
    if @token
      @token.generate_access_token
      @token.expired_at = token_params["expired_at"]
    else
      @token = @org.access_token.new(token_params)
    end

    if @token.save
      render json: ::AuthenticationTokenSerializer.new(@token, {}).serializable_hash
    else
      render json: @token.errors.full_messages, status: :bad_request
    end
  end

  def get_organization_token
    @organization = Organization.find_by(name: params[:organization_id])
    unless @organization
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @organization, to: :create_access_token?
    if @organization.access_token.nil?
      skip_verify_authorized!
      head :not_found and return
    end
    render json: ::AuthenticationTokenSerializer.new(@organization.access_token, {}).serializable_hash
  end

  def get_agent_token

  end

  def create_agent_token

  end
  def show
    @token = AccessToken.find_by(external_id: params[:token_id])
    unless verify_token_access
      head :bad_request and return
    end


  end

  def destroy
    @token = AccessToken.find_by(external_id: params[:token_id])
    unless verify_token_access
      head :bad_request and return
    end

    if @token.delete
      head :accepted and return
    end

    render json: @token.errors.full_messages, status: :bad_request
  end

  private
  def verify_token_access
    case @token.token_authable_type
    when "User"
      # Require a user token for auth
      # Ensure its the users token
    when "Organization"
      # Require authenticated entity be either
      # - member of owner team
      # - owners team token
      # - organization token
      # Ensure token is for the same organization
    when "Agent"
      # Simply require the entity have ability
      # to manage the authentication scheme
    when "Team"
      # Verify entity has access to the team
      # or is an organization admin
    else
      return false
    end
  end

  def get_token
    @token = AccessToken.find_by(external_id: params[:token_id])
  end

  def token_params
    map_params(["expired-at"])
  end
end
