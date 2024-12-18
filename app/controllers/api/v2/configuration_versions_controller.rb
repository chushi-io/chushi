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
        authorize! @workspace, to: :can_queue_run?

        version = @workspace.configuration_versions.new(
          auto_queue_runs: params[:auto_queue_runs],
          status: 'pending'
        )
        version.organization = @workspace.organization
        if version.save
          render json: ::ConfigurationVersionSerializer.new(version, {}).serializable_hash, status: :created
        else
          render json: version.errors.full_messages, status: :bad_request
        end
      end

      def download
        @version = ConfigurationVersion.find_by(external_id: params[:id])
        authorize! @version.workspace, to: :can_read_run?

        contents = @version.archive.read
        contents = Vault::Rails.decrypt('transit', 'chushi_storage_contents', contents) if contents.start_with?('vault:')

        render body: contents, layout: false
      end
    end
  end
end
