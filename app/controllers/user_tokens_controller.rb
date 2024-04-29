class UserTokensController < AuthenticatedController
  skip_before_action :set_organization!

  def index
    @tokens = current_user.access_tokens
  end

  def show
    @token = current_user.access_tokens.find(params[:id])
  end

  def new
    @token = current_user.access_tokens.new
  end

  def create
    @token = AccessToken.new(token_params)
    @token.token_authable = current_user
    if @token.save
      flash[:info] = "Access token created: #{@token.token}"
      redirect_to access_tokens_path
    else
      render "new"
    end
  end

  def destroy
    current_user.access_tokens.destroy(params[:id])
    flash[:info] = "Access token deleted"
    redirect_to access_tokens_path
  end

  private
  def token_params
    params.require(:access_token).permit(:name, :scopes, :expires_at)
  end
end