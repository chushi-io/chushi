# frozen_string_literal: true

module Api
  module V2
    class OrganizationsController < Api::ApiController
      skip_verify_authorized only: [:index]
      def entitlements
        @organization = Organization
                        .where(name: params[:organization_id])
                        .first!
        authorize! @organization, to: :read?
        render json: {
          data: {
            id: @organization.name,
            type: 'entitlement-sets',
            attributes: {
              agents: true,
              'audit-logging': false,
              'configuration-designer': true,
              'cost-estimation': false,
              'global-run-tasks': false,
              'module-tests-generation': false,
              operations: true,
              'policy-enforcement': false,
              'policy-limit': 5,
              'policy-mandatory-enforcement-limit': 0,
              'policy-set-limit': 1,
              'private-module-registry': true,
              'private-policy-agents': false,
              'private-vcs': false,
              'run-task-limit': 1,
              'run-task-mandatory-enforcement-limit': 1,
              'run-task-workspace-limit': 10,
              'run-tasks': false,
              'self-serve-billing': true,
              sentinel: false,
              sso: false,
              'state-storage': true,
              teams: false,
              'usage-reporting': false,
              'user-limit': 5,
              'vcs-integrations': true,
              'versioned-policy-set-limit': 1
            },
            links: {
              self: "/api/v2/entitlement-sets/#{params[:organization_id]}"
            }
          }
        }
      end

      def index
        render json: nil, status: :not_found and return unless current_user.present?

        @organizations = current_user.organizations
        render json: ::OrganizationSerializer.new(@organizations, {}).serializable_hash
      end

      def show
        @organization = Organization
                        .where(name: params[:organization_id])
                        .first!
        authorize! @organization, to: :read?
        render json: ::OrganizationSerializer.new(@organization, {}).serializable_hash
      end

      def create
        authorize! current_user, to: :can_create_organizations?

        org_input = org_params
        org_input['organization_type'] = org_input['type']
        puts org_input.inspect

        @organization = Organization.new(org_input.except('type'))
        @organization.users << current_user
        @owner_team = Team.new(name: 'owners', visibility: 'organization')
        @owner_team.users << current_user
        @organization.teams << @owner_team
        @organization.projects << Project.new(name: 'Default Project', is_default: true)

        if @organization.save
          render json: ::OrganizationSerializer.new(@organization, {}).serializable_hash, status: :created
        else
          render json: @organization.errors.full_messages, status: :bad_request
        end
      end

      def update
        @organization = Organization
                        .where(name: params[:organization_id])
                        .first!
        authorize! @organization, to: :is_admin?
        render json: nil, status: :bad_request and return if org_params['name']

        if @organization.update(org_params)
          render json: ::OrganizationSerializer.new(@organization, {}).serializable_hash
        else
          render json: @organization.errors.full_messages, status: :bad_request
        end
      end

      def queue
        authorize!
        @runs = Run.for_agent(current_agent.id).where(status: %w[plan_queued apply_queued])
        render json: ::RunSerializer.new(@runs, {}).serializable_hash
      end

      def tags
        @organization = Organization.find(external_id: params[:organization_id])
        if request.get?
          # Simply get the organization tags
        else
          jsonapi_deserialize(params, only: %i[
                                id
                                type
                              ])

        end
      end

      def org_params
        map_params([
                     :name,
                     :email,
                     :type,
                     'default-execution-mode'
                   ])
      end
    end
  end
end
