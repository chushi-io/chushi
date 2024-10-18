# frozen_string_literal: true

module Api
  module V2
    class ProvidersController < Api::ApiController
      def index
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :read?
        @providers = @org.providers

        render json: ::ProviderSerializer.new(@providers, {}).serializable_hash
      end

      def show
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :read?
        @provider = @org.providers.where(
          namespace: params[:namespace],
          name: params[:name]
        ).first

        render json: ::ProviderSerializer.new(@provider, {}).serializable_hash
      end

      def create
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :can_create_provider?

        @provider = @org.providers.new(provider_params)
        @provider.namespace = @org.name
        @provider.registry = 'private'
        @provider.save
        render json: ::ProviderSerializer.new(@provider, {}).serializable_hash, status: :created
      end

      def destroy; end

      private

      def provider_params
        map_params([:name])
      end
    end
  end
end
