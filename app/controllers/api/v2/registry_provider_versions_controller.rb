# frozen_string_literal: true

module Api
  module V2
    class RegistryProviderVersionsController < Api::ApiController
      def index
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :show?

        @provider = @org.providers.where(
          registry: 'private',
          namespace: params[:namespace],
          name: params[:name]
        ).first!

        render json: ::ProviderVersionSerializer.new(@provider.provider_versions, {}).serializable_hash
      end

      def show
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :show?

        @provider = @org.providers.where(
          registry: 'private',
          namespace: params[:namespace],
          name: params[:name]
        ).first!

        @version = @provider.provider_versions.where(version: params[:version]).find!

        render json: ::ProviderVersionSerializer.new(@version, {}).serializable_hash
      end

      def create
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :manage_modules?

        @provider = @org.providers.where(
          registry: 'private',
          namespace: params[:namespace],
          name: params[:name]
        ).first!

        @version = @provider.provider_versions.create(version_params)
        render json: ::ProviderVersionSerializer.new(@version, {}).serializable_hash
      end

      def destroy
        head :not_implemented
      end

      private

      def version_params
        map_params(%i[version key_id protocols])
      end
    end
  end
end
