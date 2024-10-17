# frozen_string_literal: true

module Api
  module V2
    class ModulesController < Api::ApiController
      def index
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :read?
        @registry_modules = @org.registry_modules

        render json: ::RegistryModuleSerializer.new(@registry_modules, {}).serializable_hash
      end

      def show
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :read?
        @module = @org.registry_modules.where(
          # registry: "private",
          namespace: params[:namespace],
          name: params[:name],
          provider: params[:provider]
        ).first!

        render json: ::RegistryModuleSerializer.new(@module, {}).serializable_hash
      end

      def create
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :can_create_module?
        @registry_module = @org.registry_modules.new(module_params)
        @registry_module.namespace = @org.name
        @registry_module.status = 'pending'
        if @registry_module.save
          render json: ::RegistryModuleSerializer.new(@registry_module, {}).serializable_hash, status: :created
        else
          render json: nil, status: :internal_server_error
        end
      end

      def update
        head :not_implemented
      end

      def destroy
        head :not_implemented
      end

      private

      def module_params
        map_params(%i[
                     name
                     provider
                   ])
      end
    end
  end
end
