# frozen_string_literal: true

module Registry
  module V1
    class ModulesController < Registry::RegistryController
      include ActiveStorage::SetCurrent
      def index
        @modules = RegistryModule.where(params.permit(
                                          :namespace,
                                          :name,
                                          :provider
                                        ))
        render json: @modules
      end

      def search
        head :bad_request unless params[:q]

        @modules = RegistryModule.where
        render json: @modules
      end

      def versions
        @module = RegistryModule.where(
          namespace: params[:namespace],
          name: params[:name],
          provider: params[:provider]
        ).first
        render json: {
          modules: [
            {
              source: "#{@module.namespace}/#{@module.name}/#{@module.provider}",
              versions: @module.registry_module_versions.map do |module_version|
                {
                  version: module_version.version,
                  submodules: []
                }
              end
            }
          ]
        }
      end

      def download
        @registry_module = RegistryModule.where(
          namespace: params[:namespace],
          name: params[:name],
          provider: params[:provider]
        ).first
        @version = if params[:version]
                     # Redirect to the archive path
                     @registry_module.registry_module_versions.find_by(version: params[:version])
                   else
                     # Download latest
                     @registry_module.registry_module_versions.order(version: :desc).first
                   end

        if @version.archive.present?
          response.headers['X-Terraform-Get'] =
            "#{encrypt_storage_url({ id: @version.id, class: @version.class.name })}?archive=tar.gz"
          head :no_content
        else
          head :not_found
        end
      end

      def archive
        @module = RegistryModule.where(
          namespace: params[:namespace],
          name: params[:name],
          provider: params[:provider],
          version: params[:version]
        ).first
        @module.increment!(:downloads)

        # Get the archive and download it
      end

      def latest
        @modules = RegistryModule.where(
          namespace: params[:namespace],
          name: params[:name]
        )
        # TODO: Grab all of the latest stuffs
        render json: @modules
      end

      def show; end

      def create
        @module = RegistryModule.new(
          name: params[:name],
          namespace: params[:namespace],
          provider: params[:provider],
          version: params[:version]
        )
        @module.published_at = Time.zone.now
        @module.save!
        request.body.rewind
        @module.archive.attach(io: request.body,
                               filename: "#{params[:namespace]}-#{params[:name]}-#{params[:provider]}-#{params[:version]}.tar.gz")
        render json: @module
      end

      private

      def module_params
        params.permit(:namespace, :name, :provider, :version)
      end
    end
  end
end
