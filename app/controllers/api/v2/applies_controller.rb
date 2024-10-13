# frozen_string_literal: true

module Api
  module V2
    class AppliesController < Api::ApiController
      skip_before_action :verify_access_token, only: [:logs]
      skip_verify_authorized only: :logs

      def show
        @apply = Apply.first(external_id: params[:id])
        authorize! @org, to: :read

        render json: ::ApplySerializer.new(@apply, {}).serializable_hash
      end

      def logs
        head :no_content
      end

      ### Agent-only routes
      def update; end

      def upload_logs; end
    end
  end
end
