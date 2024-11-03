# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    include JSONAPI::Deserialization
    include ActionPolicy::Controller

    prepend_before_action :set_default_response_format

    before_action :verify_access_token
    # before_action :doorkeeper_authorize!

    authorize :user, through: :current_user
    authorize :organization, through: :current_organization
    authorize :agent, through: :current_agent
    authorize :run, through: :current_run
    authorize :team, through: :current_team
    authorize :task, through: :current_task

    verify_authorized

    # Anytime we fail an authorization policy, we
    # simply return "not found". While not ideal,
    # this prevents identifying that a resource exists
    rescue_from ActionPolicy::Unauthorized do |_ex|
      render json: {}, status: :not_found
    end

    protected

    def set_default_response_format
      request.format = :json
      return if request.headers['Content-Type'].present?

      request.headers['Content-Type'] = 'application/json'
    end

    def authenticated
      token = request.headers['Authorization'].to_s.split.last
      @access_token = AccessToken.find_by(token:)
      !access_token.nil?
    end

    def verify_access_token
      if valid_doorkeeper_token?
        doorkeeper_authorize!
      else

        token = request.headers['Authorization'].to_s.split.last
        render json: nil, status: :forbidden and return if token.nil?

        token_chunks = token.split('.')

        @access_token = AccessToken.find_by(external_id: "at-#{token_chunks[0]}")
        render json: nil, status: :forbidden and return if @access_token.nil?
        render json: nil, status: :forbidden and return if @access_token.token != token_chunks[1]
        return unless @access_token.expired_at.present? && @access_token.expired_at.after?(Time.zone.now)

        render json: nil, status: :forbidden
      end
    end

    def is_organization
      @access_token&.token_authable_type == 'Organization'
    end

    def current_organization
      return unless is_organization

      Organization.find(@access_token.token_authable_id)
    end

    def current_user
      if @access_token.present?
        return nil unless @access_token.token_authable_type == 'User'

        return User.find(@access_token.token_authable_id)
      end

      current_resource_owner
    end

    def current_team
      return unless @access_token&.token_authable_type == 'Team'

      Team.find(@access_token.token_authable_id)
    end

    def current_task
      return unless @access_token&.token_authable_type == 'RunTask'

      RunTask.find(@access_token.token_authable_id)
    end

    def current_run
      return unless @access_token&.token_authable_type == 'Run'

      Run.find(@access_token.token_authable_id)
    end

    def current_agent
      return unless @access_token&.token_authable_type == 'AgentPool'

      AgentPool.find(@access_token.token_authable_id)
    end

    def map_params(attributes)
      jsonapi_deserialize(params, only: attributes).transform_keys { |key| key.gsub('-', '_') }
    end

    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def encrypt_storage_url(object)
      api_v2_get_storage_url(
        Base64.strict_encode64(
          Vault::Rails.encrypt('transit', 'chushi_storage_url', object.to_json)
        ),
        host: Chushi.domain,
        protocol: 'https'
      )
    end
  end
end
