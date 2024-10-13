# frozen_string_literal: true

class OrganizationTokensController < AuthenticatedController
  before_action -> { authorize! @organization, to: :can_update_api_token? }
  def index
    @tokens = @organization.access_tokens
  end

  def show
    @token = @organization.access_tokens.find(params[:id])
  end

  def new
    @token = @organization.access_tokens.new
  end

  def create
    @token = AccessToken.new(token_params)
    @token.token_authable = @organization

    if @token.save
      flash[:info] = "Access token created: #{@token.token}"
      redirect_to organization_access_token_path
    else
      render 'new'
    end
  end

  def destroy
    @organization.access_tokens.destroy
    flash[:info] = 'Access tokend deleted'
    redirect_to access_tokens_path
  end

  private

  def token_params
    params.require(:access_token).permit(:name, :scopes, :expires_at)
  end
end
