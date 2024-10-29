# frozen_string_literal: true

module Api
  module V2
    class PoliciesController < Api::ApiController
      def index
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :read?

        @policies = @org.policies
        render json: ::PolicySerializer.new(@policies, {}).serializable_hash
      end

      def show
        @policy = Policy.find_by(external_id: params[:id])
        unless @policy
          skip_verify_authorized!
          head :not_found and return
        end
        authorize! @policy.organization, to: :read?
        render json: ::PolicySerializer.new(@policy, {}).serializable_hash
      end

      def create
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :is_admin?

        @policy = @org.policies.new(policy_params)
        if @policy.save
          render json: ::PolicySerializer.new(@policy, {}).serializable_hash
        else
          render json: @policy.errors.full_messages, status: :bad_request
        end
      end

      def upload
        @policy = Policy.find_by(external_id: params[:id])
        unless @policy
          skip_verify_authorized!
          head :not_found and return
        end
        authorize! @policy.organization, to: :is_admin?
        request.body.rewind
        tempfile = Tempfile.new(@policy.id)
        tempfile << request.body.read
        tempfile.rewind
        @policy.policy = tempfile
        @policy.save!
        head :created
      end

      def download
        @policy = Policy.find_by(external_id: params[:id])
        unless @policy
          skip_verify_authorized!
          head :not_found and return
        end
        authorize! @policy.organization, to: :read?
        if @policy.policy.present?
          render body: @policy.policy.read, layout: false
        else
          head :bad_request
        end
      end

      private

      def policy_params
        map_params(%i[name description kind query enforcement-level])
      end
    end
  end
end
