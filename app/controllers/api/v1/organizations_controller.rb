class Api::V1::OrganizationsController < Api::ApiController
  def entitlements

  end

  def queue
    # TODO: This should be filtered on the requesting agent
    runs = Run.where(
      organization_id: params[:organization_id]
    ).where(status: %w[plan_queued apply_queued])

    render json: ::RunSerializer.new(runs, {}).serializable_hash
  end
end
