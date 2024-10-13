class Api::V2::PlansController < Api::ApiController
  skip_before_action :verify_access_token, only: [:logs]
  skip_verify_authorized only: :logs
  def show
    @plan = Plan.find_by(external_id: params[:id])
    authorize! @workspace, to: :can_access?
    render json: ::PlanSerializer.new(@plan, {}).serializable_hash
  end

  def logs
    @plan = Plan.find_by(external_id: params[:id])
    authorize! @workspace, to: :can_access?
    # Otherwise, return no content
    # Check if the file is attached. If it is, simply return it
    if @plan.plan_log_file.attached?
      # Redirect to URL and return
      head :found and return
    end

    HTTParty.get(
      "#{Chushi.timber_url}/files/#{@plan.run.id}_#{@plan.id}.log",
      { query: { limit: params[:limit], offset: params[:offset] } }
    ).body
  end

  def json_output_redacted
    @plan = Plan.find_by(external_id: params[:id])
    authorize! @workspace, to: :can_access?

    if @plan.plan_json_file.attached?
      render json: @plan.plan_json_file.download
    else
      render json: {}
    end
  end

  # Agent-only API routes
  def upload
    @run = Run.find_by(external_id: params[:id])
    authorize! @run.plan

    request.body.rewind
    @run.plan.plan_file.attach(io: request.body, filename: 'plan')
    head :ok
  end

  def upload_json
    @run = Run.find_by(external_id: params[:id])
    authorize! @run.plan, to: :upload?

    request.body.rewind
    @run.plan.plan_json_file.attach(io: request.body, filename: 'plan')
    head :ok
  end

  def upload_structured
    @run = Run.find_by(external_id: params[:id])
    authorize! @run.plan, to: :upload?

    request.body.rewind
    @run.plan.plan_structured_file.attach(io: request.body, filename: 'plan')
    head :ok
  end

  def download; end

  def update
    @plan = Plan.find_by(external_id: params[:id])

    @plan.has_changes = params[:has_changes]
    @plan.resource_additions = params[:resource_additions]
    @plan.resource_changes = params[:resource_changes]
    @plan.resource_destructions = params[:resource_destructions]
    @plan.resource_imports = params[:resource_imports]

    @plan.run.update(has_changes: true) if @plan.has_changes
    @plan.save

    render json: ::PlanSerializer.new(@plan, {}).serializable_hash
  end

  def upload_logs; end
end
