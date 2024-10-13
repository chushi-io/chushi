# frozen_string_literal: true

module Api
  module V2
    class TeamsController < Api::ApiController
      def index
        @org = Organization.find_by(external_id: params[:organization_id])
        authorize! @org, to: :read
        # If admin user
        @teams = @org.teams
        # else, only get visible teams, and secret teams I'm a member of

        render json: ::TeamSerializer.new(@teams, {}).serializable_hash
      end

      def show
        @team = Team.find_by(external_id: params[:id])
        unless @team
          skip_verify_authorized!
          head :not_found and return
        end
        authorize! @team
        render json: ::TeamSerializer.new(@team, {}).serializable_hash
      end

      def create
        @org = Organization.find_by(name: params[:organization_id])
        authorize! @org, to: :can_create_team?

        @team = @org.teams.new(team_params)
        if @team.save
          render json: ::TeamSerializer.new(@team, {}).serializable_hash
        else
          render json: @team.errors.full_messages, status: :bad_request
        end
      end

      def update
        @team = Team.find_by(external_id: params[:id])
        authorize! @team
        # For any specified params, verify permissions access to do so
        if @team.update(team_params)
          render json: ::TeamSerializer.new(@team, {}).serializable_hash
        else
          render json: @team.errors.full_messages, status: :bad_request
        end
      end

      def destroy
        @team = Team.find_by(external_id: params[:id])
        authorize! @team, to: :destroy?
        if @team.delete
          render status: :no_content
        else
          render status: :internal_server_error
        end
      end

      def add_users
        @team = Team.find_by(external_id: params[:id])
        unless @team
          skip_verify_authorized!
          head :not_found and return
        end
        authorize! @team, to: :can_update_membership?
      end

      def remove_users
        @team = Team.find_by(external_id: params[:id])
        unless @team
          skip_verify_authorized!
          head :not_found and return
        end
        authorize! @team, to: :can_update_membership?
      end

      def add_org_memberships
        @team = Team.find_by(external_id: params[:id])
        unless @team
          skip_verify_authorized!
          head :not_found and return
        end
        authorize! @team, to: :can_update_membership?
      end

      def remove_org_memberships
        @team = Team.find_by(external_id: params[:id])
        unless @team
          skip_verify_authorized!
          head :not_found and return
        end
        authorize! @team, to: :can_update_membership?
      end

      private

      def team_params
        map_params([
                     :name,
                     :description,
                     :visibility,
                     'allow-member-token-management'
                   ])
      end
    end
  end
end
