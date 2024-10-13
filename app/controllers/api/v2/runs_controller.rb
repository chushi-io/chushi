# frozen_string_literal: true

module Api
  module V2
    class RunsController < Api::ApiController
      before_action :load_run, except: [:create]
      def show
        authorize! @run.workspace, to: :can_queue_run?

        options = {}
        options[:include] = params[:include].split(',') if params[:include]
        render json: ::RunSerializer.new(@run, options).serializable_hash
      end

      def create
        @workspace = Workspace.find_by(external_id: run_params['workspace_id'])
        if run_params['plan_only']
          authorize! @workspace, to: :can_queue_run?
        else
          authorize! @workspace, to: :can_queue_apply?
        end

        @run = @workspace.organization.runs.new(run_params)
        @run.configuration_version = ConfigurationVersion.find_by(external_id: run_params['configuration_version_id']) if run_params['configuration_version_id']
        @run.workspace = @workspace

        begin
          RunCreator.call(@run)
          render json: ::RunSerializer.new(@run, {}).serializable_hash
        rescue StandardError
          render status: :internal_server_error
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
        authorize! @run, to: :can_apply
        @run.update(status: 'apply_queued')
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
        map_params([
                     'plan-only',
                     :message,
                     :workspace,
                     'is-destroy',
                     'configuration-version'
                   ])
      end
    end
  end
end
