class Api::V2::AgentsController < Api::ApiController
  def index
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :read

    @agent_pools = @org.agents
    render ::AgentPoolSerializer.new(@agent_pools, {}).serializable_hash
  end

  def show
    @agent = AgentPool.find_by(external_id: params[:id])
    authorize! @agent.organization, to: :read
    render json: ::AgentPoolSerializer.new(@agent, {}).serializable_hash
  end

  def create
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :can_update_agent_pools?

    @agent_pool = @org.agent_pools.new(agent_params)
    if @agent_pool.save
      render json: ::AgentPoolSerializer.new(@agent_pool, {}).serializable_hash
    else
      render json: @agent_pool.errors.full_messages, status: :bad_request
    end
  end

  def update
    @agent = AgentPool.find_by(external_id: params[:id])
    authorize! @agent.organization, to: :update_agent_pools?
    if @agent.update(agent_params)
      render json: ::AgentPoolSerializer.new(@agent, {}).serializable_hash
    else
      render json: @agent.errors.full_messages, status: :bad_request
    end
  end

  def destroy
    @agent = Agent.find_by(external_id: params[:id])
    authorize! @agent.organization, to: :update_agent_pools?
    if @agent.delete
      render status: :no_content
    else
      render status: :internal_server_error
    end
  end

  private

  def agent_params
    map_params([
                 'organization-scoped',
                 :name
               ])
  end
end
