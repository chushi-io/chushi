# frozen_string_literal: true

class AgentPoolsController < AuthenticatedController
  before_action lambda {
    authorize! @organization, to: :can_update_agent_pools?
  }, only: %i[new create]

  def index
    @agent_pools = @organization.agent_pools
  end

  def show
    @agent_pool = @organization.agent_pools.find_by(external_id: params[:id])
  end

  def new
    @agent_pool = @organization.agent_pools.new
  end

  def create
    @agent_pool = @organization.agent_pools.new(agent_pool_params)
    if @agent_pool.save
      @token = AccessToken.new
      @token.token_authable = @agent_pool
      @token.save!
      flash[:info] = 'Agent successfully created'
      redirect_to agent_pool_path(@organization.name, @agent_pool.external_id)
    else
      flash.error = 'Failed creating agent'
      render 'new'
    end
  end

  private

  def agent_pool_params
    params.require(:agent_pool).permit(:name, :organization_scoped)
  end
end
