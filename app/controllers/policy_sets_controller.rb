# frozen_string_literal: true

class PolicySetsController < AuthenticatedController
  before_action :load_policy_set
  before_action -> { authorize! @organization, to: :is_admin? }
  def index
    @policy_sets = @organization.policy_sets
  end

  def show
    @policy_set = @organization.policy_sets.find_by(external_id: params[:id])
  end

  def new
    @policy_set = @organization.policy_sets.new
  end

  def edit; end

  def create
    authorize! @organization, to: :is_admin?
    @policy_set = @organization.policy_sets.new(policy_set_params)
    if @policy_set.save
      redirect_to policy_set_path(@organization.name, @policy_set.external_id)
    else
      render 'new'
    end
  end

  def update; end

  def destroy
    authorize! @organization, to: :is_admin?
    @policy_set.delete
    redirect_to policy_sets_path(@organization.name)
  end

  private

  def policy_set_params
    params.require(:policy_set).permit(
      :name,
      :description,
      :global,
      :kind,
      :overrideable,
      :vcs_repo_branch,
      :vcs_repo_identifier,
      :vcs_repo_oauth_token_id
    )
  end

  def load_policy_set
    @policy_set = @organization.policy_sets.find_by(external_id: params[:id])
  end
end
