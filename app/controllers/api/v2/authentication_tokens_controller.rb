class Api::V2::AuthenticationTokensController < Api::ApiController
  before_action :get_token, only: %i[get_team_token show destroy_team_token destroy]
  def index; end

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
      @team.expired_at = token_params['expired_at']
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
    @team = Team.find_by(external_id: params[:id])
    unless @team
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @team, to: :create_access_token?
    head :accepted and return if @team.access_token.delete

    render json: @team.access_token.errors.full_messages, status: :bad_request
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
      @token.expired_at = token_params['expired_at']
    else
      @token = @org.access_token.new(token_params)
    end

    if @token.save
      render json: ::AuthenticationTokenSerializer.new(@token, {
                                                         params: { show_token: true }
                                                       }).serializable_hash
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

  def get_agent_tokens
    @agent = Agent.find_by(external_id: params[:id])
    unless @organization
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @agent, to: :create_access_token?
    render json: ::AuthenticationTokenSerializer.new(@agent.access_tokens, {}).serializable_hash
  end

  def create_agent_token
    @agent = Agent.find_by(external_id: params[:id])
    unless @agent
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @agent, to: :create_access_token?
    @token = @agent.access_tokens.create(token_params)
    if @token
      render json: ::AuthenticationTokenSerializer.new(@token, {
                                                         params: { show_token: true }
                                                       }).serializable_hash
    else
      head :bad_request
    end
  end

  def show
    @token = AccessToken.find_by(external_id: params[:token_id])
    unless @token
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @token
    render json: ::AuthenticationTokenSerializer.new(@token, {}).serializable_hash
  end

  def create_run_token
    @run = Run.find_by(external_id: params[:id])
    unless @run
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @run, to: :token?
    @token = @run.access_token
    if @token
      @token.generate_access_token
      # @token.expired_at = token_params["expired_at"]
    else
      @token = @run.create_access_token(description: 'Token for run')
    end

    if @token.save
      render json: ::AuthenticationTokenSerializer.new(@token, {
                                                         params: { show_token: true }
                                                       }).serializable_hash
    else
      render json: @token.errors.full_messages, status: :bad_request
    end
  end

  def destroy
    @token = AccessToken.find_by(external_id: params[:token_id])
    unless @token
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @token
    head :accepted and return if @token.delete

    render json: @token.errors.full_messages, status: :bad_request
  end

  private

  def get_token
    @token = AccessToken.find_by(external_id: params[:token_id])
  end

  def token_params
    map_params(['expired-at', :description])
  end
end
