class Api::V2::AccountDetailsController < Api::ApiController
  skip_verify_authorized!
  def show
    head :unauthorized unless is_user

    render json: ::UserSerializer.new(current_user, {}).serializable_hash
  end
end
