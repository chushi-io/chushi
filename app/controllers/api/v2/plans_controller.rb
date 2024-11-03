# frozen_string_literal: true

module Api
  module V2
    class PlansController < Api::ApiController
      def show
        @plan = Plan.find_by(external_id: params[:id])
        authorize! @plan.run.workspace, to: :can_queue_run?

        render json: ::PlanSerializer.new(@plan, {}).serializable_hash
      end

      def logs
        @plan = Plan.find_by(external_id: params[:id])
        authorize! @workspace, to: :can_read_run?
        # If the log file has been uploaded already, we'll
        # just redirect to the whole log file
        redirect_to encrypt_storage_url({ id: plan.id, class: @plan.class.name, filename: 'logs' }) and return if @plan.logs.present?

        HTTParty.get(
          "#{Chushi.timber_url}/files/#{@plan.run.id}_#{@plan.id}.log",
          { query: { limit: params[:limit], offset: params[:offset] } }
        ).body
      end

      def json_output_redacted
        @plan = Plan.find_by(external_id: params[:id])
        authorize! @plan.run.workspace, to: :can_read_run?

        if @plan.plan_json_file.present?
          redirect_to encrypt_storage_url({ id: @plan.id, class: @plan.class.name, filename: 'tfplan.json' })
        else
          head :no_content
        end
      end

      def download; end

      def update
        @plan = Plan.find_by(external_id: params[:id])
        authorize! @plan.run.workspace, to: :is_agent?

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
  end
end
