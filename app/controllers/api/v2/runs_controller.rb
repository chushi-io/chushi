# frozen_string_literal: true

module Api
  module V2
    class RunsController < Api::ApiController
      before_action :load_run, except: [:create]
      def show
        authorize! @run.workspace, to: :can_read_run?

        options = {}
        options[:include] = params[:include].split(',') if params[:include]
        Rails.logger.debug options.inspect
        render json: ::RunSerializer.new(@run, options).serializable_hash
      end

      def create
        @workspace = Workspace.find_by(external_id: run_params['workspace_id'])
        authorize! @workspace, to: :can_read_run?

        # We don't handle runs for local workspaces
        render json: nil, status: :bad_request and return if @workspace.execution_mode == 'local'

        if run_params['save_plan'] == false
          authorize! @workspace, to: :can_queue_run?
        else
          authorize! @workspace, to: :can_queue_apply?
        end

        @run = @workspace.organization.runs.new(run_params)
        @run.workspace = @workspace

        @run.configuration_version = if run_params['configuration_version_id']
                                       ConfigurationVersion.find_by(external_id: run_params['configuration_version_id'])
                                     else
                                       @workspace.current_configuration_version
                                     end

        if @run.message.nil?
          user_agent = request.headers['User-Agent']
          @run.message = 'Triggered by CLI' if user_agent.start_with?('OpenTofu')
        end

        begin
          RunCreator.call(@run)
          render json: ::RunSerializer.new(@run, {}).serializable_hash, status: :created
        rescue StandardError => e
          Rails.logger.error e
          render json: nil, status: :internal_server_error
        end
      end

      def discard
        authorize! @run.workspace, to: :can_queue_run?
      end

      def cancel
        authorize! @run.workspace, to: :can_cancel?
      end

      def force_cancel
        authorize! @run.workspace, to: :can_force_cancel?
      end

      def force_execute
        authorize! @run.workspace, to: :can_force_execute?
      end

      def events
        authorize! @run.workspace, to: :can_queue_run?
        render json: {}
      end

      def update
        authorize! @run.workspace, to: :can_queue_run?

        render json: ::RunSerializer.new(@run, {}).serializable_hash
      end

      def apply
        authorize! @run.workspace, to: :can_queue_apply?
        @run.update(status: 'confirmed')
        RunConfirmedJob.perform_async(@run.id)
        render json: ::RunSerializer.new(@run, {}).serializable_hash
      end

      def token
        authorize! @run, to: :token?
        @access_token = Doorkeeper::AccessToken.new(
          application_id: Doorkeeper::Application.first.id
        )
        @access_token.resource_owner = @run
        @access_token.save!
        @id_token = Doorkeeper::OpenidConnect::IdToken.new(@access_token)
        render json: {
          token: @id_token.as_jws_token
        }
      end

      def identity_token
        authorize! @run, to: :token?
      end

      private

      def load_run
        @run = Run.find_by(external_id: params[:id])
      end

      def run_params
        map_params(%i[
                     allow-empty-apply
                     allow-config-generation
                     auto-apply
                     debugging-mode
                     is-destroy
                     message
                     refresh
                     refresh-only
                     replace-addrs
                     target-addrs
                     plan-only
                     save-plan
                     workspace
                     configuration-version
                   ])
      end
    end
  end
end
