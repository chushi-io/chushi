class AgentsController < AuthenticatedController
  def index
    @agents = @organization.agents
  end

  def show
    @agent = @organization.agents.find(params[:id])
  end

  def new
    @agent = Agent.new
  end

  def create
    @agent = @organization.agents.new(agent_params)
    if @agent.save
      @token = AccessToken.new
      @token.token_authable = @agent
      @token.save!
      flash[:info] = "Agent successfully created"
      redirect_to @agent
    else
      flash.error = "Failed creating agent"
      render "new"
    end
  end

  private
  def agent_params
    params.require(:agent).permit(:name)
  end
end
