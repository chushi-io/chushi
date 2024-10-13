class Api::V2::RunTriggersController < Api::ApiController
  def index
    @workspace = Workspace.find_by(external_id: params[:id])
    unless @workspace
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @workspace, to: :can_access?
    @run_triggers = @workspace.run_triggers

    render json: ::RunTriggerSerializer.new(@run_triggers, {}).serializable_hash
  end

  def create
    @workspace = Workspace.find_by(external_id: params[:id])
    unless @workspace
      skip_verify_authorized!
      head :not_found and return
    end
    authorize! @workspace, to: :can_manage_run_triggers?
    @trigger = @workspace.run_triggers.new
    @sourceable = Workspace.find_by(external_id: run_trigger_params['sourceable_id'])
    authorize! @sourceable, to: :can_read_run?

    @trigger.sourceable = @sourceable
    if @trigger.save
      render json: ::RunTriggerSerializer.new(@trigger, {}).serializable_hash
    else
      render json: @trigger.errors.full_messages, status: :bad_request
    end
  end

  def show
    @trigger = RunTrigger.find_by(external_id: params[:id])
    unless @trigger
      skip_verify_authorized!
      head :not_found and return
    end
    authorize! @trigger.workspace, to: :can_access?
    render json: ::RunTriggerSerializer.new(@trigger, {}).serializable_hash
  end

  def destroy
    @trigger = RunTrigger.find_by(external_id: params[:id])
    authorize! @trigger.workspace, to: :can_manage_run_triggers?
    head :no_content
  end

  private

  def run_trigger_params
    map_params([:sourceable])
  end
end
