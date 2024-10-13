class Api::V2::AppliesController < Api::ApiController
  skip_before_action :verify_access_token, :only => [:logs]
  skip_verify_authorized only: :logs

  def show
    @apply = Apply.first(external_id: params[:id])
    authorize! @org, to: :read

    render json: ::ApplySerializer.new(@apply, {}).serializable_hash
  end

  def logs
    head :no_content
  end

  ### Agent-only routes
  def update

  end

  def upload_logs

  end
end
