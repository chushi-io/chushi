# frozen_string_literal: true

module Api
  module V2
    class CloudProvidersController < Api::ApiController
      def index
        @organization = Organization.find_by(name: params[:organization_id])
        authorize! @organization, to: :can_manage_cloud_providers?

        @cloud_providers = @organization.cloud_providers
        render json: ::CloudProviderSerializer.new(@cloud_providers, {}).serializable_hash
      end

      def show
        @cloud_provider = CloudProvider.find_by(external_id: params[:id])
        unless @cloud_provider
          skip_verify_authorized!
          head :not_found and return
        end
        authorize @cloud_provider.organization, to: :can_manage_cloud_providers?
        render json: ::CloudProviderSerializer.new(@cloud_provider, {}).serializable_hash
      end

      def create
        @organization = Organization.find_by(name: params[:organization_id])
        authorize! @organization, to: :can_manage_cloud_providers?
        @cloud_provider = @organization.cloud_providers.new(cloud_provider_params)
        if @cloud_provider.save
          render json: ::CloudProviderSerializer.new(@cloud_provider, {}).serializable_hash
        else
          render json: @cloud_provider.errors.full_messages, status: :bad_request
        end
      end

      def update
        @cloud_provider = CloudProvider.find_by(external_id: params[:id])
        authorize! @cloud_provider.organization, to: :can_manage_cloud_providers?
        if @cloud_provider.update(project_params)
          render json: ::CloudProviderSerializer.new(@cloud_provider, {}).serializable_hash
        else
          render json: @cloud_provider.errors.full_messages, status: :bad_request
        end
      end

      def destroy
        @cloud_provider = CloudProvider.find_by(external_id: params[:id])
        authorize! @cloud_provider.organization, to: :can_manage_cloud_providers?
        if @cloud_provider.delete
          render status: :no_content
        else
          render status: :internal_server_error
        end
      end

      private

      def cloud_provider_params
        map_params(%i[
                     cloud
                     name
                     display-name
                     aws-account-id
                     aws-access-key-id
                     aws-secret-access-key
                     aws-iam-role
                     gcp-project
                     gcp-service-account-json
                     gcp-workload-identity-provider
                     gcp-service-account-email
                   ])
      end
    end
  end
end
