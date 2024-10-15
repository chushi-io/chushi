# frozen_string_literal: true

module Api
  module V2
    class AppliesController < Api::ApiController
      def show
        @apply = Apply.find_by(external_id: params[:id])
        authorize! @apply.run.workspace, to: :can_read_run?

        render json: ::ApplySerializer.new(@apply, {}).serializable_hash
      end

      ### Agent-only routes
      def update; end

      def upload_logs; end
    end
  end
end
