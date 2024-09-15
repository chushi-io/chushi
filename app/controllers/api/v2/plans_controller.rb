class Api::V2::PlansController < Api::ApiController
  skip_before_action :verify_access_token, :only => [:logs]
  skip_verify_authorized only: :logs
  def show
    @plan = Plan.find_by(external_id: params[:id])
    authorize! @plan, to: :show?
    render json: ::PlanSerializer.new(@plan, {}).serializable_hash
  end

  def logs
    head :no_content
  end

  def upload
    @run = Run.find_by(external_id: params[:id])
    authorize! @run.plan

    request.body.rewind
    @run.plan.plan_file.attach(io: request.body, filename: "plan")
    head :ok
  end

  def upload_json
    @run = Run.find_by(external_id: params[:id])
    authorize! @run.plan, to: :upload?

    request.body.rewind
    @run.plan.plan_json_file.attach(io: request.body, filename: "plan")
    head :ok
  end

  def upload_structured
    @run = Run.find_by(external_id: params[:id])
    authorize! @run.plan, to: :upload?

    request.body.rewind
    @run.plan.plan_structured_file.attach(io: request.body, filename: "plan")
    head :ok
  end

  def download

  end

  def logs
    if request.post?
      @run = Run.find_by(external_id: params[:id])
      # authorize! @run.plan, to: :upload?

      request.body.rewind
      @run.plan.plan_log_file.attach(io: request.body, filename: "logs")
      head :ok
    else
      @plan = Plan.first(external_id: params[:id])
      # authorize! @plan, to: :show?
      head :no_content and return unless @plan.plan_log_file.attached?

      contents = @plan.plan_log_file.download.squeeze("\n")
      offset = params[:offset] || 0
      limit = params[:limit] || 65536
      # What the fuck are we doing?
      if offset.to_i > contents.length
        head :no_content
      else
        render json: contents[offset.to_i..limit.to_i]
      end
    end
  end

  def json_output_redacted
    @plan = Plan.find_by(external_id: params[:id])
    authorize! @plan, to: :show?

    if @plan.plan_json_file.attached?
      render json: @plan.plan_json_file.download
    else
      render json: {}
    end
  end

  def update
    @plan = Plan.find_by(external_id: params[:id])
    authorize! @plan

    @plan.has_changes = params[:has_changes]
    @plan.resource_additions = params[:resource_additions]
    @plan.resource_changes = params[:resource_changes]
    @plan.resource_destructions = params[:resource_destructions]
    @plan.resource_imports = params[:resource_imports]

    if @plan.has_changes
      @plan.run.update(has_changes: true)
    end
    @plan.save

    render json: ::PlanSerializer.new(@plan, {}).serializable_hash
  end
end
