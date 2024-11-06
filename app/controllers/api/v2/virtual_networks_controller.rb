# frozen_string_literal: true

module Api
  module V2
    class VirtualNetworksController < ApplicationController
      def index
        @organization = Organization.find_by(name: params[:organization_id])
        authorize! @organization, to: :can_manage_virtual_networks?

        @virtual_networks = @organization.virtual_networks
        render json: ::VirtualNetworkSerializer.new(@virtual_networks, {}).serializable_hash
      end

      def show
        @virtual_network = VirtualNetwork.find_by(external_id: params[:id])
        unless @virtual_network
          skip_verify_authorized!
          head :not_found and return
        end
        authorize @virtual_network.organization, to: :can_manage_virtual_networks?
        render json: ::VirtualNetworkSerializer.new(@virtual_network, {}).serializable_hash
      end

      def create
        @organization = Organization.find_by(name: params[:organization_id])
        authorize! @organization, to: :can_manage_virtual_networks?
        @virtual_network = @organization.virtual_networks.new(virtual_network_params)
        if @virtual_network.save
          render json: ::VirtualNetworkSerializer.new(@virtual_network, {}).serializable_hash
        else
          render json: @virtual_network.errors.full_messages, status: :bad_request
        end
      end

      def update
        @virtual_network = VirtualNetwork.find_by(external_id: params[:id])
        authorize! @virtual_network.organization, to: :can_manage_virtual_networks?
        if @virtual_network.update(project_params)
          render json: ::VirtualNetworkSerializer.new(@virtual_network, {}).serializable_hash
        else
          render json: @virtual_network.errors.full_messages, status: :bad_request
        end
      end

      def destroy
        @virtual_network = VirtualNetwork.find_by(external_id: params[:id])
        authorize! @virtual_network.organization, to: :can_manage_virtual_networks?
        if @virtual_network.delete
          render status: :no_content
        else
          render status: :internal_server_error
        end
      end

      private

      def virtual_network_params
        map_params(%i[
                     cloud
                     name
                     region
                     cidr-block
                   ])
      end
    end
  end
end
