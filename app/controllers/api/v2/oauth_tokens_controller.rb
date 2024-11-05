# frozen_string_literal: true

module Api
  module V2
    class OauthTokensController < ApplicationController
      def index
        @client = OauthClient.find_by(external_id: params[:id])
        authorize! @client.organization, to: :read?

        @tokens = @client.oauth_tokens
        render json: ::OauthTokenSerializer.new(@tokens, {}).serializable_hash
      end

      def show
        @token = OauthToken.find_by(external_id: params[:id])
        unless @token
          skip_verify_authorized!
          head :not_found and return
        end

        authorize! @token.oauth_client.organization, to: :read?
        render json: ::OauthTokenSerializer.new(@token, {}).serializable_hash
      end

      def update
        head :not_implemented
      end

      def destroy
        head :not_implemented
      end
    end
  end
end
