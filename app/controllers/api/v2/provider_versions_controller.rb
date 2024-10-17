# frozen_string_literal: true

module Api
  module V2
    class ProviderVersionsController < Api::ApiController
      def index
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :read?

        @provider = @org.providers.where(
          registry: 'private',
          namespace: params[:namespace],
          name: params[:name]
        ).first!

        render json: ::ProviderVersionSerializer.new(@provider.provider_versions, {}).serializable_hash
      end

      def show
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :read?

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
        authorize! @org, to: :can_create_provider?

        puts "Org authorized"
        puts params.inspect
        @provider = @org.providers.where(
          registry: 'private',
          namespace: @org.name,
          name: params[:name]
        ).first!

        @version = @provider.provider_versions.create(version_params)
        render json: ::ProviderVersionSerializer.new(@version, {}).serializable_hash, status: :created
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
