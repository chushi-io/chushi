# frozen_string_literal: true

module Api
  module V2
    class ModuleVersionsController < Api::ApiController
      def create
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :can_create_module?
        @module = @org.registry_modules.where(
          # registry: "private",
          namespace: @org.name,
          name: params[:name],
          provider: params[:provider]
        ).first!

        @version = @module.registry_module_versions.new(version_params)
        @version.status = 'pending'
        @version.source = 'tfe-api'
        @version.save

        render json: ::RegistryModuleVersionSerializer.new(@version, {}).serializable_hash, status: :created
      end

      def destroy
        # Find the version, and delete it
        head :not_implemented
      end

      private

      def version_params
        map_params(%i[version commit_sha])
      end
    end
  end
end
