# frozen_string_literal: true

module Api
  class ApiController < ActionController::API
    include JSONAPI::Deserialization
    include ActionPolicy::Controller

    before_action :set_default_response_format

    before_action :verify_access_token

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
    end

    def authenticated
      token = request.headers['Authorization'].to_s.split.last
      @access_token = AccessToken.find_by(token:)
      !access_token.nil?
    end

    def verify_access_token
      token = request.headers['Authorization'].to_s.split.last
      render json: nil, status: :forbidden and return if token.nil?

      token_chunks = token.split('.')

      @access_token = AccessToken.find_by(external_id: "at-#{token_chunks[0]}")
      render json: nil, status: :forbidden and return if @access_token.nil?
      render json: nil, status: :forbidden and return if @access_token.token != token_chunks[1]
      return unless @access_token.expired_at.present? && @access_token.expired_at.after?(Time.zone.now)

      render json: nil, status: :forbidden
    end

    def is_organization
      @access_token.token_authable_type == 'Organization'
    end

    def current_organization
      return unless is_organization

      Organization.find(@access_token.token_authable_id)
    end

    def is_user
      @access_token.token_authable_type == 'User'
    end

    def current_user
      return unless is_user

      User.find(@access_token.token_authable_id)
    end

    def current_team
      return unless @access_token.token_authable_type == 'Team'

      Team.find(@access_token.token_authable_id)
    end

    def current_task
      return unless @access_token.token_authable_type == 'RunTask'

      RunTask.find(@access_token.token_authable_id)
    end

    def is_run
      @access_token.token_authable_type == 'Run'
    end

    def current_run
      return unless is_run

      Run.find(@access_token.token_authable_id)
    end

    def is_agent
      @access_token.token_authable_type == 'Agent'
    end

    def current_agent
      return unless is_agent

      AgentPool.find(@access_token.token_authable_id)
    end

    def verify_organization_access
      if current_organization
        render json: {}, status: :forbidden unless current_organization.id == params[:organization_id]
        @organization = current_organization
      elsif current_user
        @organization = current_user.organizations.find(params[:organization_id])
        render json: {}, status: :forbidden unless @organization
      elsif current_run
        @organization = current_run.organization
        render json: {}, status: :forbidden unless @organization
      else
        @agent = current_agent
        @organization = @agent.organization
      end
    end

    def can_access_workspace(workspace)
      return workspace.agent_pool_id == current_agent.id if current_agent

      ## TODO for now, we just verify access to the organization
      can_access_organization(workspace.organization_id)
    end

    def can_access_run(run)
      if current_agent
        return run.agent_id == current_agent.id
      elsif current_run
        return current_run.id == run.id
      end

      can_access_organization(run.organization_id)
    end

    def can_access_organization(organization_id)
      if current_organization && current_organization != organization_id
        false
      elsif current_agent
        return current_agent.organization.id == organization_id
      else
        return false unless current_user.organizations.find(organization_id)
      end
      true
    end

    def map_params(attributes)
      jsonapi_deserialize(params, only: attributes).transform_keys { |key| key.gsub('-', '_') }
    end
  end
end
