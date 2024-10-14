# frozen_string_literal: true

module Api
  module V2
    class AccountDetailsController < Api::ApiController
      skip_verify_authorized
      def show
        head :unauthorized unless is_user

        render json: ::UserSerializer.new(current_user, {}).serializable_hash
      end
    end
  end
end
