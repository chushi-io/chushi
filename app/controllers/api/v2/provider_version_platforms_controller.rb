# frozen_string_literal: true

module Api
  module V2
    class ProviderVersionPlatformsController < Api::ApiController
      before_action :load_organization
      before_action :load_provider
      before_action :load_version
      def index
        authorize! @org, to: :read?
        render json: ::ProviderVersionPlatformSerializer.new(@version.provider_version_platforms, {}).serializable_hash
      end

      def show
        authorize! @org, to: :read?
        @platform = @version.provider_version_platforms.where(
          os: params[:os],
          arch: params[:arch]
        ).first!
        render json: ::ProviderVersionPlatformSerializer.new(@platform, {}).serializable_hash
      end

      def create
        authorize! @org, to: :can_create_provider?
        @platform = @version.provider_version_platforms.create(platform_params)
        output = ::ProviderVersionPlatformSerializer.new(@platform, {}).serializable_hash
        Rails.logger.debug output
        render json: output, status: :created
      end

      def destroy
        head :not_implemented
      end

      private

      def load_organization
        @org = Organization.find_by(name: params[:organization_id])
      end

      def load_provider
        @provider = @org.providers.where(
          registry: 'private',
          namespace: params[:namespace],
          name: params[:name]
        ).first!
      end

      def load_version
        @version = @provider.provider_versions.where(version: params[:version]).first!
      end

      def platform_params
        map_params(%i[os arch shasum filename])
      end
    end
  end
end
