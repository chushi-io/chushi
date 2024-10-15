# frozen_string_literal: true

module Api
  module V2
    class ConfigurationVersionsController < Api::ApiController
      def show
        @version = ConfigurationVersion.find_by(external_id: params[:id])
        authorize! @version.workspace, to: :can_read_run?
        render json: ::ConfigurationVersionSerializer.new(@version, {}).serializable_hash
      end

      def create
        @workspace = Workspace.find_by(external_id: params[:id])
        authorize! @workspace, to: :can_queue_runs?

        version = @workspace.configuration_versions.new(
          auto_queue_runs: params[:auto_queue_runs],
          status: 'pending'
        )
        version.organization = @workspace.organization
        if version.save
          render json: ::ConfigurationVersionSerializer.new(version, {}).serializable_hash
        else
          render json: version.errors.full_messages, status: :bad_request
        end
      end

      def download
        @version = ConfigurationVersion.find_by(external_id: params[:id])
        authorize! @version.workspace, to: :can_queue_runs?

        contents = @version.archive.read
        if contents.start_with?('vault:')
          contents = Vault::Rails.decrypt('transit', 'chushi_storage_contents',
                                          obj.read)
        end

        render body: contents, layout: false
      end
    end
  end
end
