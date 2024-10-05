class Api::V2::AccountDetailsController < Api::ApiController
  def show
    unless is_user
      head :unauthorized
    end

    skip_verify_authorized!
    render json: ::UserSerializer.new(current_user, {}).serializable_hash
  end
end
