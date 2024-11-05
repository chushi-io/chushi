class Api::V2::OauthClientsController < ApplicationController
  def index
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :read?

    @oauth_clients = @org.oauth_clients
    render json: ::OauthClientSerializer.new(@oauth_clients, {}).serializable_hash
  end

  def show
    @oauth_client = OauthClient.find_by(external_id: params[:id])
    unless @oauth_client
      skip_verify_authorized!
      head :not_found and return
    end
    authorize! @oauth_client.organization, to: :read?
    render json: ::OauthClientSerializer.new(@oauth_client, {}).serializable_hash
  end

  def create
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :can_update_oauth?

    @oauth_client = @org.oauth_clients.new(project_params)
    if @oauth_client.save
      render json: ::OauthClientSerializer.new(@oauth_client, {}).serializable_hash
    else
      render json: @oauth_client.errors.full_messages, status: :bad_request
    end
  end

  def update

  end

  def destroy

  end

  private
  def oauth_client_params
    map_params(%i[
      service-provider
      name
      key
      http-url
      api-url
      oauth-token-string
      private-key
      secret
      rsa-public-key
      organization-scoped
    ])
  end
end
