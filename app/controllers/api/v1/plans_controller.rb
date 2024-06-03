class Api::V1::PlansController < Api::ApiController
  skip_before_action :verify_access_token, :only => [:logs]
  skip_verify_authorized only: :logs
  def show
    @plan = Plan.find(params[:id])
    authorize! @plan, to: :show?
    render json: ::PlanSerializer.new(@plan, {}).serializable_hash
  end

  def logs
    head :no_content
  end

  def upload
    @run = Run.find(params[:id])
    authorize! @run.plan

    request.body.rewind
    @run.plan.plan_file.attach(io: request.body, filename: "plan")
    head :ok
  end

  def upload_json
    @run = Run.find(params[:id])
    authorize! @run.plan, to: :upload?

    puts request.body
    request.body.rewind
    @run.plan.plan_json_file.attach(io: request.body, filename: "plan")
    head :ok
  end

  def upload_structured
    @run = Run.find(params[:id])
    authorize! @run.plan, to: :upload?

    request.body.rewind
    @run.plan.plan_structured_file.attach(io: request.body, filename: "plan")
    head :ok
  end

  def download

  end

  def logs
    if request.post?
      @run = Run.find(params[:id])
      # authorize! @run.plan, to: :upload?

      request.body.rewind
      @run.plan.plan_log_file.attach(io: request.body, filename: "logs")
      head :ok
    else
      @plan = Plan.find(params[:id])
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
    @plan = Plan.find(params[:id])
    authorize! @plan, to: :show?

    if @plan.plan_json_file.attached?
      render json: @plan.plan_json_file.download
    else
      render json: {}
    end
  end

  def update
    @plan = Plan.find(params[:id])
    authorize! @plan

    puts params
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

# 22:59:20 server.1   | Started GET "/api/v1/plans/b8e6fd60-1ddd-498f-834a-704f787e8eed/logs?limit=65536&offset=0" for 74.70.224.53 at 2024-05-28 22:59:20 -0400
# 22:59:20 server.1   | Cannot render console from 74.70.224.53! Allowed networks: 127.0.0.0/127.255.255.255, ::1
# 22:59:20 server.1   | Processing by Api::V1::PlansController#logs as JSON
# 22:59:20 server.1   |   Parameters: {"limit"=>"65536", "offset"=>"0", "id"=>"b8e6fd60-1ddd-498f-834a-704f787e8eed"}
# 22:59:20 server.1   | Completed 204 No Content in 0ms (ActiveRecord: 0.0ms | Allocations: 27)
# 22:59:20 server.1   |
# 22:59:20 server.1   |
# 22:59:20 sidekiq.1  | 2024-05-29T02:59:20.231Z pid=1681 tid=
