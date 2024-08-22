class Api::V1::AppliesController < Api::ApiController
  skip_before_action :verify_access_token, :only => [:logs]
  skip_verify_authorized only: :logs

  def show
    @apply = Apply.first(external_id: params[:id])
    authorize! @apply

    render json: ::ApplySerializer.new(@apply, {}).serializable_hash
  end

  def logs
    head :no_content
  end
end
