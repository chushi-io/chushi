# frozen_string_literal: true

class PoliciesController < AuthenticatedController
  before_action :load_policy, only: %i[edit show update destroy]
  before_action lambda {
    authorize! @organization, to: :is_admin?
  }, only: %i[new create update destroy]

  def index
    @policies = @organization.policies
  end

  def show; end

  def new
    @policy = @organization.policies.new
  end

  def edit; end

  def create
    @policy = @organization.policies.new(policy_params)
    if @policy.save
      redirect_to policy_path(@organization.name, @policy.external_id)
    else
      render 'new'
    end
  end

  def update; end

  def destroy
    @policy_set.delete
    redirect_to policies_path(@organization.name)
  end

  private

  def policy_params
    params.require(:policy).permit(
      :name,
      :description,
      :type,
      :query,
      :enforcement_level
    )
  end

  def load_policy
    @policy = @organization.policies.find_by(external_id: params[:id])
  end
end
