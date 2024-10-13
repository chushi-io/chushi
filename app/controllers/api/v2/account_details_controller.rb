class Api::V2::AccountDetailsController < Api::ApiController
  skip_verify_authorized!
  def show
    unless is_user
      head :unauthorized
    end

    render json: ::UserSerializer.new(current_user, {}).serializable_hash
  end
end
